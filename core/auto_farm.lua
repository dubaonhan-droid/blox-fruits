-- core/auto_farm.lua
-- Bot farm Blox Fruits — Luồng đơn giản, tuần tự, dễ hiểu

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local MobData = nil

local AutoFarm = {}

function AutoFarm.SetMobData(data)
    MobData = data
    print("[Bot] ✅ Đã nhận dữ liệu quái (" .. #data .. " loại)")
end

-- ═══════════════════════════════════════
-- CẤU HÌNH
-- ═══════════════════════════════════════
local TWEEN_SPEED = 150
local FLOAT_HEIGHT = 20

-- ═══════════════════════════════════════
-- HÀM CÔNG CỤ
-- ═══════════════════════════════════════

--- Bay đến 1 vị trí
local function Bay(pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Giữ lơ lửng
    local bv = hrp:FindFirstChild("FarmFloat")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FarmFloat"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
    end

    local dist = (hrp.Position - pos).Magnitude
    local t = dist / TWEEN_SPEED
    local tween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

--- Tắt lơ lửng
local function TatBay()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = char.HumanoidRootPart:FindFirstChild("FarmFloat")
        if bv then bv:Destroy() end
    end
end

--- Lấy level nhân vật
local function LayLevel()
    local ok, lv = pcall(function()
        return LocalPlayer:WaitForChild("Data", 5):WaitForChild("Level", 5).Value
    end)
    return ok and lv or 1
end

--- Tìm mobData theo level
local function TimMobData(level)
    for _, data in ipairs(MobData) do
        if level >= data.MinLevel and level <= data.MaxLevel then
            return data
        end
    end
    return nil
end

--- Kiểm tra màn hình CÓ nhiệm vụ không (tìm số X/Y trong Main GUI)
local function CoBangNhiemVu()
    local ok, result = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return false end
        local main = pg:FindFirstChild("Main")
        if not main then return false end
        
        for _, obj in ipairs(main:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local cur, mx = string.match(obj.Text, "(%d+)/(%d+)")
                if cur and mx then
                    local c, m = tonumber(cur), tonumber(mx)
                    if m > 0 and m <= 50 and c < m then
                        return true -- Đang có nhiệm vụ chưa xong
                    end
                end
            end
        end
        return false
    end)
    return ok and result or false
end

--- Nhận quest qua CommF_
local function NhanQuest(questName, questLevel)
    local ok, resp = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", questName, questLevel)
    end)
    print("[Bot] CommF_ → ok=" .. tostring(ok) .. " resp=" .. tostring(resp))
end

--- Tìm NPC theo tên (tìm gần đúng)
local function TimNPC(ten)
    local tenLower = string.lower(ten)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
            if string.find(string.lower(obj.Name), tenLower) then
                return obj
            end
        end
    end
    return nil
end

--- Gom quái về trước mặt
local function GomQuai(mobName)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local target = hrp.CFrame * CFrame.new(0, -2, -5)

    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    local mobLower = string.lower(mobName)

    for _, obj in ipairs(enemies:GetChildren()) do
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
            local n = string.lower(obj.Name)
            if n == mobLower or string.find(n, mobLower) then
                obj.HumanoidRootPart.CFrame = target
                obj.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                obj.HumanoidRootPart.CanCollide = false
            end
        end
    end
end

--- Rút vũ khí ra (bấm phím 1/2/3)
local function RutVuKhi(loai)
    local key = Enum.KeyCode.One -- Mặc định Melee = phím 1
    if loai == "Sword" then key = Enum.KeyCode.Two end
    if loai == "Blox Fruit" then key = Enum.KeyCode.Three end
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

--- Đánh quái (click chuột)
local function DanhQuai()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
    
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end

-- ═══════════════════════════════════════
-- VÒNG LẶP CHÍNH
-- ═══════════════════════════════════════

function AutoFarm.Start(UI)
    if AutoFarm._isRunning then return end
    AutoFarm._isRunning = true

    task.spawn(function()
        print("[Bot] 🟢 Bot bắt đầu!")

        while AutoFarm._isRunning do
            -- Chờ user bật toggle
            if not UI.Settings.AutoFarm then
                task.wait(0.5)
                continue
            end

            -- ══════════════════════════════════
            -- BƯỚC 1: Kiểm tra level
            -- ══════════════════════════════════
            local level = LayLevel()
            local mobData = TimMobData(level)

            if not mobData then
                print("[Bot] ⚠️ Không có bãi farm cho level " .. level)
                task.wait(3)
                continue
            end

            if not mobData.QuestNpcPosition or not mobData.FarmPosition then
                print("[Bot] ⚠️ Chưa có tọa độ cho " .. mobData.MobName .. " (cần điền vào mob_data.lua)")
                task.wait(3)
                continue
            end

            print("[Bot] 📊 Level " .. level .. " → Farm: " .. mobData.MobName)

            -- ══════════════════════════════════
            -- BƯỚC 2: Bay đến NPC nhận nhiệm vụ
            -- ══════════════════════════════════
            if not CoBangNhiemVu() then
                print("[Bot] 📋 Chưa có nhiệm vụ → Bay đến NPC...")
                Bay(mobData.QuestNpcPosition)
                TatBay()
                task.wait(2)

                -- Tìm NPC thật để bay sát
                local npc = TimNPC(mobData.QuestGiverName)
                if npc and npc:FindFirstChild("HumanoidRootPart") then
                    print("[Bot] ✅ Thấy NPC: " .. npc.Name)
                    Bay(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
                    task.wait(0.5)
                end

                -- Gửi lệnh nhận quest
                NhanQuest(mobData.QuestName, mobData.QuestLevel)
                task.wait(1)
            else
                print("[Bot] 📋 Đang có nhiệm vụ, bỏ qua bước nhận quest")
            end

            -- ══════════════════════════════════
            -- BƯỚC 3: Bay đến bãi farm
            -- ══════════════════════════════════
            print("[Bot] ⚔️ Bay đến bãi farm...")
            Bay(mobData.FarmPosition + Vector3.new(0, FLOAT_HEIGHT, 0))

            -- Bấm phím 1 lần để rút vũ khí ra (Melee=1, Sword=2, DF=3)
            RutVuKhi(UI.Settings.WeaponType or "Melee")
            task.wait(0.5)

            -- Click 1 phát để bắt đầu tự động đánh
            DanhQuai()
            task.wait(0.3)

            -- ══════════════════════════════════
            -- BƯỚC 4: Farm đến khi hết nhiệm vụ
            -- ══════════════════════════════════
            print("[Bot] ⚔️ Đang farm " .. mobData.MobName .. "!")
            local lastBring = 0

            while UI.Settings.AutoFarm do
                -- Check còn nhiệm vụ không
                if not CoBangNhiemVu() then
                    print("[Bot] ✅ Hết nhiệm vụ! Quay lại nhận quest mới...")
                    break
                end

                -- Gom quái về trước mặt
                if os.clock() - lastBring > 0.5 then
                    GomQuai(mobData.MobName)
                    lastBring = os.clock()
                end

                -- Click liên tục để đánh (giữ combo)
                DanhQuai()

                -- Tốc độ
                if UI.Settings.FastAttack then
                    task.wait()
                else
                    task.wait(0.2)
                end
            end

            -- ══════════════════════════════════
            -- BƯỚC 5: Kiểm tra level mới
            -- ══════════════════════════════════
            TatBay()
            local newLevel = LayLevel()
            local newMobData = TimMobData(newLevel)
            if newMobData and newMobData ~= mobData then
                print("[Bot] 🎉 Lên level mới! Chuyển sang: " .. newMobData.MobName)
            end

            task.wait(0.5)
        end

        TatBay()
        print("[Bot] 🔴 Bot đã dừng.")
    end)
end

function AutoFarm.Stop()
    AutoFarm._isRunning = false
    TatBay()
    print("[Bot] 🔴 Dừng bot.")
end

return AutoFarm
