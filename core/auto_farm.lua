local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local AutoFarm = {}

local TWEEN_SPEED = 300
local FLOAT_HEIGHT = 20 
local ATTACK_RANGE = 5  

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

-- === CÁC HÀM XỬ LÝ (SỬ DỤNG DỮ LIỆU ĐỘNG) ===

-- Nhận Quest theo dữ liệu mobData
function AutoFarm.GetQuest(mobData)
    -- Thay vì hardcode "Quest Giver", giờ ta dùng mobData.QuestGiverName
    local questGiver = Workspace:FindFirstChild(mobData.QuestGiverName)
    if questGiver and questGiver:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = questGiver.HumanoidRootPart.Position + Vector3.new(0, 0, 5)
        TweenToPosition(targetCFrame)
        FloatPlayer(false) 
        task.wait(0.5)
        
        -- Gọi RemoteEvent và truyền tên Quest động
        -- Ví dụ: CommF_:InvokeServer("StartQuest", mobData.QuestName, mobData.QuestLevel)
        print("Đã nhận nhiệm vụ " .. mobData.QuestName .. "!")
    end
end

-- Gom quái theo tên (mobData.MobName)
local function BringMobs(mobName)
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local character = LocalPlayer.Character
    if not enemiesFolder or not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local bringCFrame = hrp.CFrame * CFrame.new(0, -2, -ATTACK_RANGE)
    
    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj.Name == mobName and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
            obj.HumanoidRootPart.CFrame = bringCFrame
            obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            obj.HumanoidRootPart.Size = Vector3.new(10, 10, 10) 
            obj.HumanoidRootPart.CanCollide = false
        end
    end
end

-- Tìm quái theo tên
function AutoFarm.GoToMob(mobData)
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end

    local targetMob = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, obj in ipairs(enemiesFolder:GetChildren()) do
        if obj.Name == mobData.MobName and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
            local distance = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                targetMob = obj
            end
        end
    end

    if targetMob then
        local mobPos = targetMob.HumanoidRootPart.Position
        local targetPos = mobPos + Vector3.new(0, FLOAT_HEIGHT, 0)
        TweenToPosition(targetPos)
        return targetMob
    end

    return nil
end

-- Tấn công
function AutoFarm.Attack(targetMob, mobData)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    local humanoid = character.Humanoid

    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then humanoid:EquipTool(tool) end
    local equippedTool = character:FindFirstChildOfClass("Tool")

    while targetMob and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 do
        FloatPlayer(true)
        BringMobs(mobData.MobName) -- Chỉ gom quái có tên trong cấu hình
        
        if equippedTool then
            equippedTool:Activate()
        end
        task.wait(0.1)
    end
end

-- Vòng lặp Tổng được viết lại để nhận Data
function AutoFarm.Start(mobData)
    task.spawn(function()
        while true do
            -- Kiểm tra nếu chưa có quest thì gọi GetQuest(mobData)
            -- AutoFarm.GetQuest(mobData)
            
            local currentMob = AutoFarm.GoToMob(mobData)
            if currentMob then
                AutoFarm.Attack(currentMob, mobData)
            end
            task.wait(0.1)
        end
    end)
end

return AutoFarm
