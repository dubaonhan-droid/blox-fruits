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
local TWEEN_SPEED = 300   -- Tốc độ bay (studs/giây)
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
    if enemies then
        for _, obj in ipairs(enemies:GetChildren()) do
            if (obj.Name == mobName or string.find(obj.Name, mobName))
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

--- Kiểm tra quest đã hoàn thành chưa (code Blox Fruits thật)
function AutoFarm.IsQuestComplete()
    local success, result = pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local mainGui = playerGui:FindFirstChild("Main")
            if mainGui then
                local questFrame = mainGui:FindFirstChild("Quest")
                -- Nếu Quest frame tồn tại và đang hiển thị (Visible == true) -> Đang có quest
                if questFrame and questFrame.Visible == true then
                    return false -- Đang làm quest, chưa hoàn thành
                end
            end
        end
        return true -- Không thấy UI Quest = Đã hoàn thành hoặc chưa nhận
    end)
    return success and result or true
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
function AutoFarm.GetQuest(mobData)
    -- Tránh nhận lại quest nếu đang có quest
    if not AutoFarm.IsQuestComplete() then
        return
    end

    print("[AutoFarm] Bước 1: Đi nhận quest từ " .. mobData.QuestGiverName .. "...")

    -- Tìm NPC quest (tìm đệ quy trong toàn Workspace)
    local questGiver = FindNPC(mobData.QuestGiverName)
    
    if questGiver then
        -- Bay đến NPC
        local npcPos = questGiver.HumanoidRootPart.Position + Vector3.new(0, 0, 5)
        TweenToPosition(npcPos)
        FloatPlayer(false)
        task.wait(1) -- Chờ chạm đất và load NPC
        
        -- Gọi Remote nhận quest
        pcall(function()
            local args = {
                [1] = "StartQuest",
                [2] = mobData.QuestName,
                [3] = mobData.QuestLevel
            }
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
        end)
        print("[AutoFarm] ✅ Đã gửi lệnh nhận quest: " .. mobData.QuestName)
        task.wait(1)
    elseif mobData.QuestNpcPosition then
        print("[AutoFarm] Đang bay tới tọa độ đảo để tìm NPC...")
        TweenToPosition(mobData.QuestNpcPosition)
        FloatPlayer(false)
        task.wait(1)
        
        -- Thử tìm lại NPC sau khi đảo đã load
        questGiver = FindNPC(mobData.QuestGiverName)
        if questGiver then
            local npcPos = questGiver.HumanoidRootPart.Position + Vector3.new(0, 0, 5)
            TweenToPosition(npcPos)
            task.wait(0.5)
        end
        
        pcall(function()
            local args = {
                [1] = "StartQuest",
                [2] = mobData.QuestName,
                [3] = mobData.QuestLevel
            }
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
        end)
        print("[AutoFarm] ✅ Đã gửi lệnh nhận quest (từ tọa độ): " .. mobData.QuestName)
        task.wait(1)
    else
        print("[AutoFarm] ⚠️ Không tìm thấy NPC: " .. mobData.QuestGiverName)
    end
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
                local equippedTool = character:FindFirstChildOfClass("Tool")
                
                if not equippedTool or equippedTool.ToolTip ~= targetWeaponType then
                    local toolToEquip = nil
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") and item.ToolTip == targetWeaponType then
                            toolToEquip = item
                            break
                        end
                    end
                    if toolToEquip then
                        humanoid:EquipTool(toolToEquip)
                        equippedTool = toolToEquip
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
    -- Bước 1: Nhận quest
    AutoFarm.GetQuest(mobData)
    task.wait(0.5)

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
