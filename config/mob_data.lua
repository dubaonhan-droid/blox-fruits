-- config/mob_data.lua
-- Bảng cấu hình quái vật First Sea (Level 1 → 200+)
-- Khi lên đảo mới, bạn CHỈ CẦN thêm 1 entry vào đây, không cần đụng code chạy!

local MobData = {
    -- ═══════════════════════════════════════════════
    -- 🏝️ STARTER ISLAND (Level 1–14)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 1,
        MaxLevel = 9,
        MobName = "Bandit",
        QuestName = "BanditQuest1",
        QuestLevel = 1,
        QuestGiverName = "Bandit Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 10,
        MaxLevel = 14,
        MobName = "Trainee",
        QuestName = "TraineeQuest",
        QuestLevel = 1,
        QuestGiverName = "Bandit Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- 🌴 JUNGLE (Level 15–29)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 15,
        MaxLevel = 22,
        MobName = "Monkey",
        QuestName = "JungleQuest",
        QuestLevel = 1,
        QuestGiverName = "Adventurer",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 23,
        MaxLevel = 29,
        MobName = "Gorilla",
        QuestName = "JungleQuest",
        QuestLevel = 2,
        QuestGiverName = "Adventurer",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- 🏴‍☠️ PIRATE VILLAGE (Level 30–59)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 30,
        MaxLevel = 44,
        MobName = "Pirate",
        QuestName = "PirateQuest",
        QuestLevel = 1,
        QuestGiverName = "Rick",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 45,
        MaxLevel = 59,
        MobName = "Brute",
        QuestName = "PirateQuest",
        QuestLevel = 2,
        QuestGiverName = "Rick",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- 🏜️ DESERT (Level 60–89)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 60,
        MaxLevel = 74,
        MobName = "Desert Bandit",
        QuestName = "DesertQuest",
        QuestLevel = 1,
        QuestGiverName = "Desert Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 75,
        MaxLevel = 89,
        MobName = "Desert Officer",
        QuestName = "DesertQuest",
        QuestLevel = 2,
        QuestGiverName = "Desert Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- ❄️ FROZEN VILLAGE (Level 90–119)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 90,
        MaxLevel = 104,
        MobName = "Snow Bandit",
        QuestName = "SnowQuest",
        QuestLevel = 1,
        QuestGiverName = "Snow Village Villager",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 105,
        MaxLevel = 119,
        MobName = "Snowman",
        QuestName = "SnowQuest",
        QuestLevel = 2,
        QuestGiverName = "Snow Village Villager",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- ⚓ MARINE FORTRESS (Level 120–149)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 120,
        MaxLevel = 134,
        MobName = "Chief Petty Officer",
        QuestName = "MarineQuest",
        QuestLevel = 1,
        QuestGiverName = "Marine Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 135,
        MaxLevel = 149,
        MobName = "Petty Officer",
        QuestName = "MarineQuest",
        QuestLevel = 2,
        QuestGiverName = "Marine Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- ☁️ SKYLANDS (Level 150–189)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 150,
        MaxLevel = 169,
        MobName = "Sky Bandit",
        QuestName = "SkyQuest",
        QuestLevel = 1,
        QuestGiverName = "Sky Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 170,
        MaxLevel = 189,
        MobName = "Dark Master",
        QuestName = "SkyQuest",
        QuestLevel = 2,
        QuestGiverName = "Sky Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- 🔒 PRISON (Level 190–209)
    -- ═══════════════════════════════════════════════
    {
        MinLevel = 190,
        MaxLevel = 199,
        MobName = "Prisoner",
        QuestName = "PrisonQuest",
        QuestLevel = 1,
        QuestGiverName = "Prison Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },
    {
        MinLevel = 200,
        MaxLevel = 209,
        MobName = "Dangerous Prisoner",
        QuestName = "PrisonQuest",
        QuestLevel = 2,
        QuestGiverName = "Prison Quest Giver",
        QuestNpcPosition = nil,
        FarmPosition = nil,
    },

    -- ═══════════════════════════════════════════════
    -- THÊM MAP MỚI Ở ĐÂY (Colosseum 225+, Magma 300+, ...)
    -- ═══════════════════════════════════════════════
}

return MobData
