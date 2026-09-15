-- config/mob_data.lua
-- Bảng cấu hình quái vật theo cấp độ
-- Khi lên đảo mới, bạn CHỈ CẦN thêm 1 entry vào đây, không cần đụng code chạy!

local MobData = {
    {
        MinLevel = 1,
        MaxLevel = 14,
        MobName = "Bandit",
        QuestName = "BanditQuest1",
        QuestLevel = 1,
        QuestGiverName = "Quest Giver",
        -- Vị trí NPC nhận quest (thay bằng tọa độ thật trong game)
        QuestNpcPosition = nil, -- Vector3.new(x, y, z)
        -- Vị trí trung tâm bãi farm (thay bằng tọa độ thật trong game)
        FarmPosition = nil, -- Vector3.new(x, y, z)
    },
    {
        MinLevel = 15,
        MaxLevel = 29,
        MobName = "Monkey",
        QuestName = "JungleQuest",
        QuestLevel = 1,
        QuestGiverName = "Jungle Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 30,
        MaxLevel = 9999,
        MobName = "Gorilla",
        QuestName = "JungleQuest",
        QuestLevel = 2,
        QuestGiverName = "Jungle Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    -- ═══════════════════════════════════════════════
    -- THÊM MAP MỚI Ở ĐÂY. Ví dụ:
    -- {
    --     MinLevel = 100,
    --     MaxLevel = 149,
    --     MobName = "Pirate",
    --     QuestName = "PirateQuest",
    --     QuestLevel = 1,
    --     QuestGiverName = "Pirate Quest Giver",
    --     QuestNpcPosition = Vector3.new(100, 10, 200),
    --     FarmPosition = Vector3.new(150, 10, 250),
    -- },
    -- ═══════════════════════════════════════════════
}

return MobData
