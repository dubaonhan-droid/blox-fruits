-- core/auto_farm.lua
-- Module farm tuần tự: Nhận Quest → Bay đến bãi → Farm → Quest xong → Kiểm tra level → Lặp lại
-- KHÔNG tự load file khác (app.lua lo hết), KHÔNG dùng task.spawn chồng chéo.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local MobData = nil -- Sẽ được truyền vào từ app.lua qua SetMobData()

local AutoFarm = {}

-- Nhận MobData từ app.lua
function AutoFarm.SetMobData(data)
    MobData = data
    print("[AutoFarm] ✅ Đã nhận dữ liệu quái vật (" .. (data and #data or 0) .. " loại)")
end


-- ═══════════════════════════════════════════════
-- CẤU HÌNH
-- ═══════════════════════════════════════════════
local TWEEN_SPEED = 150   -- Tốc độ bay an toàn (giảm từ 300 xuống 150 để không bị giật lùi do Anti-Cheat)
local FLOAT_HEIGHT = 20   -- Độ cao lơ lửng trên quái
local ATTACK_RANGE = 5    -- Khoảng cách gom quái trước mặt

-- ═══════════════════════════════════════════════
-- HÀM PHỤ TRỢ (PRIVATE)
-- ═══════════════════════════════════════════════

--- Giữ người chơi lơ lửng trên không bằng BodyVelocity
local function FloatPlayer(enable)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local bv = hrp:FindFirstChild("FarmFloat")
    if enable then
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "FarmFloat"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
        end
    else
        if bv then bv:Destroy() end
    end
end

--- Di chuyển nhân vật bằng Tween (bay mượt)
local function TweenToPosition(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetPosition).Magnitude
    local timeToReach = distance / TWEEN_SPEED

    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local goal = {CFrame = CFrame.new(targetPosition)}
    local tween = TweenService:Create(hrp, tweenInfo, goal)

    FloatPlayer(true)
    tween:Play()
    tween.Completed:Wait()
end

--- Tìm tất cả quái trong Workspace.Enemies để tránh gom nhầm NPC
local function FindAllMobs(mobName)
    local mobs = {}
    local enemies = Workspace:FindFirstChild("Enemies")
    local mobNameLower = string.lower(mobName)
    
    if enemies then
        for _, obj in ipairs(enemies:GetChildren()) do
            local objNameLower = string.lower(obj.Name)
            -- Tìm theo tên tiếng Anh HOẶC tên tiếng Việt (phòng khi game dịch tên obj)
            if (objNameLower == mobNameLower or string.find(objNameLower, mobNameLower) or 
               (mobNameLower == "sky bandit" and string.find(objNameLower, "cướp thiên không")))
                and obj:FindFirstChild("Humanoid") 
                and obj.Humanoid.Health > 0 
                and obj:FindFirstChild("HumanoidRootPart") then
                table.insert(mobs, obj)
            end
        end
    end
    return mobs
end

--- Gom tất cả quái có tên `mobName` về trước mặt người chơi
local function BringMobs(mobName)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = character.HumanoidRootPart
    local bringCFrame = hrp.CFrame * CFrame.new(0, -2, -ATTACK_RANGE)

    for _, obj in ipairs(FindAllMobs(mobName)) do
        obj.HumanoidRootPart.CFrame = bringCFrame
        obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        obj.HumanoidRootPart.CanCollide = false
    end
end

--- Tìm con quái gần nhất có tên `mobName`, trả về object hoặc nil
local function FindNearestMob(mobName)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local targetMob = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(FindAllMobs(mobName)) do
        local distance = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            targetMob = obj
        end
    end

    return targetMob
end

-- ═══════════════════════════════════════════════
-- HÀM CHÍNH (PUBLIC) — TỪNG BƯỚC TUẦN TỰ
-- ═══════════════════════════════════════════════

--- Lấy cấp độ hiện tại của người chơi (code Blox Fruits thật)
function AutoFarm.GetPlayerLevel()
    local success, level = pcall(function()
        return LocalPlayer:WaitForChild("Data", 5):WaitForChild("Level", 5).Value
    end)
    if success and level then
        return level
    end
    warn("[AutoFarm] ⚠️ Không đọc được level, dùng mặc định = 1")
    return 1
end

--- Tìm cấu hình quái phù hợp theo level từ mob_data.lua
function AutoFarm.GetMobDataByLevel(level)
    for _, data in ipairs(MobData) do
        if level >= data.MinLevel and level <= data.MaxLevel then
            return data
        end
    end
    return nil
end

--- Kiểm tra quest đã hoàn thành chưa (Chỉ tìm trong Main GUI)
function AutoFarm.IsQuestComplete()
    local success, result = pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return true end
        
        local mainGui = playerGui:FindFirstChild("Main")
        if not mainGui then return true end
        
        -- Chỉ quét bên trong Main GUI (nơi chứa quest tracker)
        for _, obj in ipairs(mainGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local current, max = string.match(obj.Text, "(%d+)/(%d+)")
                if current and max then
                    local currentNum = tonumber(current)
                    local maxNum = tonumber(max)
                    -- Quest tracker: maxNum nhỏ (≤50) VÀ chưa hoàn thành (current < max)
                    if maxNum > 0 and maxNum <= 50 and currentNum < maxNum then
                        return false -- Quest đang hoạt động và CHƯA xong
                    end
                end
            end
        end
        
        return true -- Không có quest hoạt động
    end)
    
    if not success then
        print("[AutoFarm] ⚠️ Lỗi UI khi check Quest: " .. tostring(result))
        return true -- Nếu lỗi thì cho nhận quest mới luôn
    end
    
    return result
end

--- Tìm NPC đệ quy trong Workspace (tìm tên gần đúng)
local function FindNPC(npcName)
    local targetName = string.lower(npcName)
    local function search(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj:FindFirstChild("HumanoidRootPart") and string.find(string.lower(obj.Name), targetName) then
                return obj
            elseif obj:IsA("Folder") or obj:IsA("Model") then
                local found = search(obj)
                if found then return found end
            end
        end
        return nil
    end
    return search(Workspace)
end

--- BƯỚC 1: Di chuyển đến NPC và nhận quest
--- Thử NHIỀU cách nhận quest khác nhau + Debug log chi tiết
function AutoFarm.GetQuest(mobData)
    print("══════════════════════════════════════")
    print("[AutoFarm] Bước 1: Đi nhận quest...")
    print("[AutoFarm] QuestName = " .. tostring(mobData.QuestName))
    print("[AutoFarm] QuestLevel = " .. tostring(mobData.QuestLevel))
    print("[AutoFarm] NPC = " .. tostring(mobData.QuestGiverName))
    print("══════════════════════════════════════")

    -- Hàm gọi Remote nhận quest (có debug log)
    local function CallStartQuest()
        local ok, response = pcall(function()
            return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", mobData.QuestName, mobData.QuestLevel)
        end)
        print("[AutoFarm] CommF_ StartQuest → ok=" .. tostring(ok) .. " response=" .. tostring(response))
        return ok, response
    end

    -- Bay đến tọa độ NPC
    local targetPos = mobData.QuestNpcPosition
    if not targetPos then
        -- Thử tìm NPC trong Workspace
        local npc = FindNPC(mobData.QuestGiverName)
        if npc and npc:FindFirstChild("HumanoidRootPart") then
            targetPos = npc.HumanoidRootPart.Position
            print("[AutoFarm] Tìm thấy NPC trong Workspace tại: " .. tostring(targetPos))
        else
            print("[AutoFarm] ⚠️ Không có tọa độ NPC và không tìm thấy NPC!")
            return
        end
    end

    -- Bay đến NPC
    print("[AutoFarm] Bay đến tọa độ: " .. tostring(targetPos))
    TweenToPosition(targetPos)
    FloatPlayer(false)
    task.wait(2) -- Chờ đảo load lâu hơn

    -- Tìm NPC thật để bay sát
    local questGiver = FindNPC(mobData.QuestGiverName)
    if questGiver and questGiver:FindFirstChild("HumanoidRootPart") then
        print("[AutoFarm] ✅ Tìm thấy NPC: " .. questGiver.Name)
        local npcPos = questGiver.HumanoidRootPart.Position + Vector3.new(0, 0, 3)
        TweenToPosition(npcPos)
        task.wait(0.5)
    else
        print("[AutoFarm] ⚠️ Không tìm thấy NPC bằng tên, quét tất cả NPC gần đó...")
        -- Debug: In ra tất cả Model có Humanoid trong vùng 100 studs
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local myPos = character.HumanoidRootPart.Position
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
                    local dist = (myPos - obj.HumanoidRootPart.Position).Magnitude
                    if dist < 100 and obj ~= character then
                        print("[DEBUG] NPC gần: " .. obj.Name .. " (cách " .. math.floor(dist) .. " studs)")
                    end
                end
            end
        end
    end

    -- === THỬ CÁCH 1: CommF_ InvokeServer (Cách phổ biến nhất) ===
    print("[AutoFarm] 🔄 Thử Cách 1: CommF_ InvokeServer...")
    CallStartQuest()
    task.wait(1)

    -- Kiểm tra đã nhận chưa
    if not AutoFarm.IsQuestComplete() then
        print("[AutoFarm] ✅ Cách 1 THÀNH CÔNG! Đã nhận quest!")
        return
    end

    -- === THỬ CÁCH 2: Thử với QuestLevel khác (0-indexed thay vì 1-indexed) ===
    print("[AutoFarm] 🔄 Thử Cách 2: QuestLevel khác...")
    for testLevel = 0, 3 do
        if testLevel ~= mobData.QuestLevel then
            pcall(function()
                local resp = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", mobData.QuestName, testLevel)
                print("[AutoFarm] QuestLevel=" .. testLevel .. " → " .. tostring(resp))
            end)
            task.wait(0.5)
            if not AutoFarm.IsQuestComplete() then
                print("[AutoFarm] ✅ Cách 2 THÀNH CÔNG với QuestLevel=" .. testLevel)
                return
            end
        end
    end

    -- === THỬ CÁCH 3: Thử tên quest khác phổ biến ===
    print("[AutoFarm] 🔄 Thử Cách 3: Tên quest khác...")
    local altQuestNames = {"SkyQuest", "SkySkyQuest", "SkyBanditQuest", "Sky1Quest", "SkyIslandQuest"}
    for _, qName in ipairs(altQuestNames) do
        if qName ~= mobData.QuestName then
            for testLevel = 1, 2 do
                pcall(function()
                    local resp = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, testLevel)
                    print("[AutoFarm] Quest=" .. qName .. " Level=" .. testLevel .. " → " .. tostring(resp))
                end)
                task.wait(0.3)
                if not AutoFarm.IsQuestComplete() then
                    print("[AutoFarm] ✅ Cách 3 THÀNH CÔNG! Quest=" .. qName .. " Level=" .. testLevel)
                    return
                end
            end
        end
    end

    -- === THỬ CÁCH 4: Tương tác trực tiếp với NPC (ClickDetector / ProximityPrompt) ===
    print("[AutoFarm] 🔄 Thử Cách 4: Click trực tiếp NPC...")
    if questGiver then
        for _, desc in ipairs(questGiver:GetDescendants()) do
            if desc:IsA("ClickDetector") then
                print("[AutoFarm] Tìm thấy ClickDetector!")
                pcall(function() fireclickdetector(desc) end)
                task.wait(1)
            elseif desc:IsA("ProximityPrompt") then
                print("[AutoFarm] Tìm thấy ProximityPrompt!")
                pcall(function() fireproximityprompt(desc) end)
                task.wait(1)
            end
        end
    end

    print("[AutoFarm] ❌ TẤT CẢ các cách đều thất bại! Kiểm tra Output log để debug.")
    print("══════════════════════════════════════")
end

--- BƯỚC 2: Bay đến bãi farm
function AutoFarm.GoToFarmArea(mobData)
    print("[AutoFarm] Bước 2: Bay đến bãi farm " .. mobData.MobName .. "...")

    if mobData.FarmPosition then
        -- Dùng tọa độ cố định từ config
        local targetPos = mobData.FarmPosition + Vector3.new(0, FLOAT_HEIGHT, 0)
        TweenToPosition(targetPos)
    else
        -- Nếu chưa có tọa độ cố định, tìm con quái gần nhất rồi bay đến
        local mob = FindNearestMob(mobData.MobName)
        if mob then
            local targetPos = mob.HumanoidRootPart.Position + Vector3.new(0, FLOAT_HEIGHT, 0)
            TweenToPosition(targetPos)
        else
            print("[AutoFarm] ⚠️ Không tìm thấy " .. mobData.MobName .. " trên map.")
        end
    end
    
    print("[AutoFarm] ✅ Đã đến bãi farm " .. mobData.MobName)
end

--- BƯỚC 3: Farm quái cho đến khi quest hoàn thành
function AutoFarm.FarmUntilQuestDone(mobData, UI)
    print("[AutoFarm] Bước 3: Bắt đầu farm " .. mobData.MobName .. "...")

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    local humanoid = character.Humanoid

    FloatPlayer(true)

    while not AutoFarm.IsQuestComplete() do
        if not UI.Settings.AutoFarm then
            print("[AutoFarm] ⏹️ Người dùng đã tắt Auto Farm.")
            FloatPlayer(false)
            return
        end

        local targetMob = FindNearestMob(mobData.MobName)
        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
            local mobPos = targetMob.HumanoidRootPart.Position
            local targetPos = mobPos + Vector3.new(0, FLOAT_HEIGHT, 0)
            TweenToPosition(targetPos)
            
            local lastBring = 0
            while targetMob 
                and targetMob:FindFirstChild("Humanoid") 
                and targetMob.Humanoid.Health > 0 
                and UI.Settings.AutoFarm 
                and not AutoFarm.IsQuestComplete() do
                
                -- Cập nhật vũ khí theo cài đặt (Melee, Sword, Blox Fruit)
                local targetWeaponType = UI.Settings.WeaponType or "Melee"
                local targetLower = string.lower(targetWeaponType)
                local equippedTool = character:FindFirstChildOfClass("Tool")
                
                local function isCorrectTool(item)
                    if not item:IsA("Tool") then return false end
                    local tt = string.lower(item.ToolTip or "")
                    local name = string.lower(item.Name or "")
                    
                    if string.find(tt, targetLower) then return true end
                    -- Hỗ trợ tiếng Việt hoặc các tên đặc biệt
                    if targetLower == "melee" and (string.find(tt, "võ") or string.find(tt, "cận chiến") or string.find(name, "combat") or string.find(name, "step") or string.find(name, "kung") or string.find(name, "claw") or string.find(name, "karate")) then return true end
                    if targetLower == "sword" and (string.find(tt, "kiếm") or string.find(tt, "đao")) then return true end
                    if targetLower == "blox fruit" and (string.find(tt, "trái") or string.find(tt, "ác quỷ") or string.find(tt, "fruit")) then return true end
                    return false
                end

                if not equippedTool or not isCorrectTool(equippedTool) then
                    local toolToEquip = nil
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if isCorrectTool(item) then
                            toolToEquip = item
                            break
                        end
                    end
                    
                    if toolToEquip then
                        humanoid:EquipTool(toolToEquip)
                        equippedTool = toolToEquip
                    end
                    
                    -- Bổ sung: Mô phỏng bấm phím số (Slot 1, 2, 3) cho các bản mobile executor hay lỗi EquipTool
                    local keyToPress = nil
                    if targetLower == "melee" then keyToPress = Enum.KeyCode.One
                    elseif targetLower == "sword" then keyToPress = Enum.KeyCode.Two
                    elseif targetLower == "blox fruit" then keyToPress = Enum.KeyCode.Three
                    end
                    
                    if keyToPress then
                        VirtualInputManager:SendKeyEvent(true, keyToPress, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, keyToPress, false, game)
                    end
                end

                -- Gom quái (chỉ chạy mỗi 0.5s để chống giật lag)
                if os.clock() - lastBring > 0.5 then
                    BringMobs(mobData.MobName)
                    lastBring = os.clock()
                end
                
                if equippedTool then
                    if UI.Settings.WeaponType == "Blox Fruit" then
                        -- Tự động tung skill (Z, X, C, V, F)
                        local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
                        for _, key in ipairs(keys) do
                            VirtualInputManager:SendKeyEvent(true, key, false, game)
                            VirtualInputManager:SendKeyEvent(false, key, false, game)
                        end
                    else
                        -- Đánh thường (Melee / Sword)
                        equippedTool:Activate()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end
                end
                
                -- Xử lý tốc độ đánh
                if UI.Settings.FastAttack then
                    task.wait() -- Siêu nhanh (theo RunService)
                else
                    task.wait(0.2) -- Tốc độ bình thường
                end
            end
        else
            -- Không có quái, đợi respawn
            task.wait(1)
        end
    end

    FloatPlayer(false)
    print("[AutoFarm] ✅ Quest " .. mobData.QuestName .. " hoàn thành!")
end

-- ═══════════════════════════════════════════════
-- VÒNG LẶP CHÍNH — 1 VÒNG LẶP DUY NHẤT
-- ═══════════════════════════════════════════════

--- Chạy 1 chu kỳ farm tuần tự (nhận quest → farm → quest xong)
function AutoFarm.RunCycle(mobData, UI)
    -- Bước 1: Nhận quest (chỉ bay về NPC nếu chưa có quest)
    if AutoFarm.IsQuestComplete() then
        AutoFarm.GetQuest(mobData)
        task.wait(0.5)
    else
        print("[AutoFarm] Đang có quest, bỏ qua bước nhận quest...")
    end

    -- Bước 2: Bay đến bãi farm
    AutoFarm.GoToFarmArea(mobData)
    task.wait(0.5)

    -- Bước 3: Farm cho đến khi quest hoàn thành
    AutoFarm.FarmUntilQuestDone(mobData, UI)
end

--- Điểm khởi chạy chính — gọi từ app.lua
--- Chạy trong 1 task.spawn DUY NHẤT, không tạo thêm thread nào khác
function AutoFarm.Start(UI)
    -- Dùng cờ để chặn gọi Start() nhiều lần
    if AutoFarm._isRunning then
        print("[AutoFarm] ⚠️ Bot đang chạy rồi, không cần gọi lại.")
        return
    end
    AutoFarm._isRunning = true

    task.spawn(function()
        print("[AutoFarm] 🟢 Bot bắt đầu hoạt động!")
        
        while AutoFarm._isRunning do
            -- Chờ cho đến khi người dùng bật Auto Farm
            if not UI.Settings.AutoFarm then
                task.wait(0.5)
                continue
            end

            -- Kiểm tra level và tìm cấu hình quái phù hợp
            local currentLevel = AutoFarm.GetPlayerLevel()
            local mobData = AutoFarm.GetMobDataByLevel(currentLevel)

            if mobData then
                print("[AutoFarm] 📊 Level " .. currentLevel .. " → Farm: " .. mobData.MobName)
                
                -- Chạy 1 chu kỳ farm tuần tự
                AutoFarm.RunCycle(mobData, UI)
                
                -- Quest xong → kiểm tra lại level (có thể đã lên vùng mới)
                local newLevel = AutoFarm.GetPlayerLevel()
                if AutoFarm.GetMobDataByLevel(newLevel) ~= mobData then
                    print("[AutoFarm] 🎉 Lên level mới! Chuyển vùng farm...")
                end
            else
                print("[AutoFarm] ⚠️ Không tìm thấy bãi farm cho level " .. currentLevel)
                task.wait(3)
            end

            task.wait(0.5)
        end

        print("[AutoFarm] 🔴 Bot đã dừng.")
    end)
end

--- Dừng bot hoàn toàn
function AutoFarm.Stop()
    AutoFarm._isRunning = false
    FloatPlayer(false)
    print("[AutoFarm] 🔴 Đã gửi lệnh dừng bot.")
end

return AutoFarm
