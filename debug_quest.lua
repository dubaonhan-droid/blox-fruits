-- debug_quest.lua
-- Script debug: Chạy riêng để kiểm tra quest system
-- Chỉ cần chạy 1 lần, ĐỌC OUTPUT rồi gửi cho dev

print("═══════════════════════════════════════")
print("🔍 BẮT ĐẦU DEBUG QUEST SYSTEM")
print("═══════════════════════════════════════")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- 1. In Level hiện tại
print("")
print("📊 THÔNG TIN NHÂN VẬT:")
pcall(function()
    local lv = LocalPlayer:WaitForChild("Data", 5):WaitForChild("Level", 5).Value
    print("   Level = " .. tostring(lv))
end)

-- 2. In vị trí hiện tại
pcall(function()
    local pos = LocalPlayer.Character.HumanoidRootPart.Position
    print("   Vị trí = " .. tostring(pos))
end)

-- 3. Kiểm tra Remotes có tồn tại không
print("")
print("📡 KIỂM TRA REMOTES:")
local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
if remotes then
    print("   ✅ Remotes folder tồn tại")
    local commF = remotes:FindFirstChild("CommF_")
    if commF then
        print("   ✅ CommF_ tồn tại (ClassName: " .. commF.ClassName .. ")")
    else
        print("   ❌ CommF_ KHÔNG tồn tại!")
        -- Liệt kê tất cả remote
        print("   Các Remote có:")
        for _, r in ipairs(remotes:GetChildren()) do
            print("      - " .. r.Name .. " (" .. r.ClassName .. ")")
        end
    end
else
    print("   ❌ Remotes folder KHÔNG tồn tại!")
end

-- 4. Quét tất cả NPC gần vị trí QuestNpcPosition
print("")
print("👤 QUÉT NPC GẦN TỌA ĐỘ QUEST (-4818.2, 927.4, -922.1):")
local questPos = Vector3.new(-4818.2, 927.4, -922.1)
local npcCount = 0
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
        local dist = (questPos - obj.HumanoidRootPart.Position).Magnitude
        if dist < 200 then
            npcCount = npcCount + 1
            print("   [" .. npcCount .. "] " .. obj.Name .. " | Khoảng cách: " .. math.floor(dist) .. " studs | HP: " .. obj.Humanoid.Health)
        end
    end
end
if npcCount == 0 then
    print("   ⚠️ Không tìm thấy NPC/Mob nào gần tọa độ quest!")
    print("   → Có thể đảo chưa load. Hãy tự bay đến đảo trước rồi chạy lại script này.")
end

-- 5. Quét NPC gần vị trí nhân vật hiện tại
print("")
print("👤 QUÉT NPC GẦN VỊ TRÍ HIỆN TẠI CỦA BẠN:")
pcall(function()
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local count2 = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
            local dist = (myPos - obj.HumanoidRootPart.Position).Magnitude
            if dist < 100 and obj ~= LocalPlayer.Character then
                count2 = count2 + 1
                print("   [" .. count2 .. "] " .. obj.Name .. " | Cách: " .. math.floor(dist) .. " studs")
            end
        end
    end
    if count2 == 0 then
        print("   ⚠️ Không có NPC/Mob nào gần bạn!")
    end
end)

-- 6. Thử gọi CommF_ StartQuest
print("")
print("🎯 THỬ NHẬN QUEST:")
local questTests = {
    {"SkyQuest", 1},
    {"SkyQuest", 2},
    {"SkyQuest", 0},
    {"Sky1Quest", 1},
    {"SkyBanditQuest", 1},
    {"Skyland", 1},
    {"SkyIslandQuest", 1},
}

for _, test in ipairs(questTests) do
    local qName, qLevel = test[1], test[2]
    local ok, resp = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qLevel)
    end)
    print("   Quest='" .. qName .. "' Level=" .. qLevel .. " → ok=" .. tostring(ok) .. " resp=" .. tostring(resp))
    task.wait(0.3)
end

-- 7. Kiểm tra UI Quest sau khi thử nhận
print("")
print("📱 KIỂM TRA UI SAU KHI THỬ NHẬN QUEST:")
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local main = pg:FindFirstChild("Main")
        if main then
            print("   ✅ Main GUI tồn tại")
            local quest = main:FindFirstChild("Quest")
            if quest then
                print("   ✅ Quest frame tồn tại | Visible = " .. tostring(quest.Visible))
                -- In tất cả TextLabel bên trong Quest
                for _, obj in ipairs(quest:GetDescendants()) do
                    if obj:IsA("TextLabel") then
                        print("      TextLabel: '" .. obj.Text .. "' | Visible=" .. tostring(obj.Visible))
                    end
                end
            else
                print("   ⚠️ Quest frame KHÔNG tồn tại trong Main")
                -- Liệt kê con của Main
                print("   Các con của Main:")
                for _, child in ipairs(main:GetChildren()) do
                    print("      - " .. child.Name .. " (" .. child.ClassName .. ") Visible=" .. tostring(pcall(function() return child.Visible end) and child.Visible or "N/A"))
                end
            end
        else
            print("   ❌ Main GUI KHÔNG tồn tại!")
        end
    end
end)

-- 8. Quét toàn bộ TextLabel có chứa số/số trên màn hình
print("")
print("🔢 TẤT CẢ TEXTLABEL CÓ DẠNG 'SỐ/SỐ' TRÊN MÀN HÌNH:")
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local count3 = 0
        for _, sg in ipairs(pg:GetChildren()) do
            if sg:IsA("ScreenGui") then
                for _, obj in ipairs(sg:GetDescendants()) do
                    if obj:IsA("TextLabel") then
                        local cur, mx = string.match(obj.Text, "(%d+)/(%d+)")
                        if cur and mx then
                            count3 = count3 + 1
                            print("   [" .. count3 .. "] GUI=" .. sg.Name .. " | Path=" .. obj:GetFullName() .. " | Text='" .. obj.Text .. "'")
                        end
                    end
                end
            end
        end
        if count3 == 0 then
            print("   Không tìm thấy TextLabel nào có dạng số/số")
        end
    end
end)

print("")
print("═══════════════════════════════════════")
print("✅ DEBUG HOÀN TẤT! Chụp OUTPUT gửi cho dev")
print("═══════════════════════════════════════")
