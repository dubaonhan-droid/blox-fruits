local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local BanditFarm = {}

-- === CẤU HÌNH ===
local TWEEN_SPEED = 300
local FLOAT_HEIGHT = 20 -- Độ cao an toàn (đứng cách quái 20 studs trên không)
local ATTACK_RANGE = 5  -- Gom quái cách người chơi 5 studs để chém

-- Giữ người chơi lơ lửng trên không (Dùng BodyVelocity)
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
            bv.Velocity = Vector3.new(0, 0, 0) -- Khóa tốc độ rơi
            bv.Parent = hrp
        end
    else
        if bv then bv:Destroy() end
    end
end

-- Hàm tạo Tween di chuyển
local function TweenToPosition(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetPosition).Magnitude
    local timeToReach = distance / TWEEN_SPEED
    
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local goal = {CFrame = CFrame.new(targetPosition)}
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    
    FloatPlayer(true) -- Bật lơ lửng khi bay để không bị rơi xuống đất
    tween:Play()
    tween.Completed:Wait()
end

-- 1. Hàm Nhận Nhiệm Vụ (GetQuest)
function BanditFarm.GetQuest()
    local questGiver = Workspace:FindFirstChild("Quest Giver")
    if questGiver and questGiver:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = questGiver.HumanoidRootPart.Position + Vector3.new(0, 0, 5)
        TweenToPosition(targetCFrame)
        FloatPlayer(false) -- Chạm đất để nhận nhiệm vụ
        task.wait(0.5)
        
        -- [GỌI REMOTE EVENT Ở ĐÂY ĐỂ NHẬN NHIỆM VỤ]
        print("Đã nhận nhiệm vụ Bandit!")
    end
end

-- [TÍNH NĂNG MỚI] Hàm gom quái
local function BringMobs()
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local character = LocalPlayer.Character
    if not enemiesFolder or not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    -- Vị trí gom quái: ngay trước mặt người chơi, hơi thấp xuống dưới chân một chút
    local bringCFrame = hrp.CFrame * CFrame.new(0, -2, -ATTACK_RANGE)
    
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj.Name == "Bandit" and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
            -- Dịch chuyển quái đến vị trí trước mặt người chơi
            obj.HumanoidRootPart.CFrame = bringCFrame
            obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            
            -- Phóng to hitbox của quái để chắc chắn chém trúng (bypass cơ bản)
            obj.HumanoidRootPart.Size = Vector3.new(10, 10, 10) 
            obj.HumanoidRootPart.Transparency = 0.5 -- Làm mờ để dễ nhìn
            obj.HumanoidRootPart.CanCollide = false
        end
    end
end

-- 2. Hàm Tìm và Di Chuyển (GoToMob)
function BanditFarm.GoToMob()
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end

    local targetMob = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    -- Quét tìm Bandit
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj.Name == "Bandit" and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
            local distance = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                targetMob = obj
            end
        end
    end

    if targetMob then
        -- Di chuyển đến vị trí CAO HƠN quái (FLOAT_HEIGHT) để an toàn
        local mobPos = targetMob.HumanoidRootPart.Position
        local targetPos = mobPos + Vector3.new(0, FLOAT_HEIGHT, 0)
        TweenToPosition(targetPos)
        return targetMob
    end

    return nil
end

-- 3. Hàm Tấn Công (Attack)
function BanditFarm.Attack(targetMob)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    local humanoid = character.Humanoid

    -- Tìm và Equip vũ khí
    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then humanoid:EquipTool(tool) end
    local equippedTool = character:FindFirstChildOfClass("Tool")

    -- Vòng lặp tấn công
    while targetMob and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 do
        FloatPlayer(true) -- Đảm bảo luôn lơ lửng không bị rớt
        BringMobs()       -- Liên tục gom tất cả Bandit trên map lại chỗ mình
        
        if equippedTool then
            equippedTool:Activate() -- Gọi hành động chém
        end
        task.wait(0.1)
    end
end

-- 4. Vòng lặp Tổng (Farm)
function BanditFarm.Farm()
    task.spawn(function()
        while true do
            -- BanditFarm.GetQuest()
            local currentMob = BanditFarm.GoToMob()
            if currentMob then
                BanditFarm.Attack(currentMob)
            end
            task.wait(0.1)
        end
    end)
end

return BanditFarm
