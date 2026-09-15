-- core/auto_farm.lua
-- Module farm tuần tự: Nhận Quest → Bay đến bãi → Farm → Quest xong → Kiểm tra level → Lặp lại
-- KHÔNG tự load file khác (app.lua lo hết), KHÔNG dùng task.spawn chồng chéo.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

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

--- Gom tất cả quái có tên `mobName` về trước mặt người chơi
local function BringMobs(mobName)
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local character = LocalPlayer.Character
    if not enemiesFolder or not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = character.HumanoidRootPart
    local bringCFrame = hrp.CFrame * CFrame.new(0, -2, -ATTACK_RANGE)

    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj.Name == mobName 
            and obj:FindFirstChild("Humanoid") 
            and obj.Humanoid.Health > 0 
            and obj:FindFirstChild("HumanoidRootPart") then
            
            obj.HumanoidRootPart.CFrame = bringCFrame
            obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            obj.HumanoidRootPart.CanCollide = false
        end
    end
end

--- Tìm con quái gần nhất có tên `mobName`, trả về object hoặc nil
local function FindNearestMob(mobName)
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local targetMob = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj.Name == mobName 
            and obj:FindFirstChild("Humanoid") 
            and obj.Humanoid.Health > 0 
            and obj:FindFirstChild("HumanoidRootPart") then
            
            local distance = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                targetMob = obj
            end
        end
    end

    return targetMob
end

-- ═══════════════════════════════════════════════
-- HÀM CHÍNH (PUBLIC) — TỪNG BƯỚC TUẦN TỰ
-- ═══════════════════════════════════════════════

--- Lấy cấp độ hiện tại của người chơi
function AutoFarm.GetPlayerLevel()
    -- TODO: Thay bằng code thật trong Roblox
    -- return game:GetService("Players").LocalPlayer.Data.Level.Value
    return 20 -- Giả lập đang ở cấp 20
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

--- Kiểm tra quest đã hoàn thành chưa
function AutoFarm.IsQuestComplete()
    -- TODO: Thay bằng code thật trong Roblox
    -- Ví dụ: kiểm tra UI quest hoặc RemoteFunction
    -- return game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("QuestComplete") ~= nil
    
    -- Giả lập: quest hoàn thành sau khi không còn quái nào sống
    -- Trong thực tế cần kiểm tra quest progress từ server
    return false
end

--- BƯỚC 1: Di chuyển đến NPC và nhận quest
function AutoFarm.GetQuest(mobData)
    print("[AutoFarm] Bước 1: Đi nhận quest từ " .. mobData.QuestGiverName .. "...")

    -- Tìm NPC quest trong Workspace
    local questGiver = Workspace:FindFirstChild(mobData.QuestGiverName)
    
    if questGiver and questGiver:FindFirstChild("HumanoidRootPart") then
        -- Bay đến NPC
        local npcPos = questGiver.HumanoidRootPart.Position + Vector3.new(0, 0, 5)
        TweenToPosition(npcPos)
        FloatPlayer(false) -- Hạ xuống đất để nhận quest
        task.wait(0.5)
        
        -- Gọi Remote để nhận quest
        -- TODO: Thay bằng remote thật
        -- game:GetService("ReplicatedStorage").CommF_:InvokeServer("StartQuest", mobData.QuestName, mobData.QuestLevel)
        print("[AutoFarm] ✅ Đã nhận quest: " .. mobData.QuestName)
    elseif mobData.QuestNpcPosition then
        -- Nếu NPC bị ẩn, dùng tọa độ cố định từ config
        TweenToPosition(mobData.QuestNpcPosition)
        FloatPlayer(false)
        task.wait(0.5)
        print("[AutoFarm] ✅ Đã nhận quest (dùng tọa độ cố định): " .. mobData.QuestName)
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

    -- Equip vũ khí
    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then humanoid:EquipTool(tool) end

    -- Vòng lặp farm — DỪNG khi quest hoàn thành hoặc người dùng tắt AutoFarm
    while not AutoFarm.IsQuestComplete() do
        -- Kiểm tra nếu người dùng tắt Auto Farm
        if not UI.Settings.AutoFarm then
            print("[AutoFarm] ⏹️ Người dùng đã tắt Auto Farm.")
            FloatPlayer(false)
            return
        end

        -- Tìm quái gần nhất
        local targetMob = FindNearestMob(mobData.MobName)

        if targetMob then
            -- Bay đến vị trí trên đầu quái
            local mobPos = targetMob.HumanoidRootPart.Position
            local targetPos = mobPos + Vector3.new(0, FLOAT_HEIGHT, 0)
            TweenToPosition(targetPos)

            -- Gom quái + tấn công cho đến khi con này chết
            FloatPlayer(true)
            local equippedTool = character:FindFirstChildOfClass("Tool")
            
            while targetMob 
                and targetMob:FindFirstChild("Humanoid") 
                and targetMob.Humanoid.Health > 0 
                and UI.Settings.AutoFarm do
                
                BringMobs(mobData.MobName)
                
                if equippedTool then
                    equippedTool:Activate()
                end
                task.wait(0.1)
            end
        else
            -- Không có quái, đợi respawn
            task.wait(1)
        end

        task.wait(0.1)
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
