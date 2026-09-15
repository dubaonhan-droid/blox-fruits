local MobData = {
    {
        MinLevel = 1,
        MaxLevel = 14,
        MobName = "Bandit",
        QuestName = "BanditQuest1",
        QuestLevel = 1, -- Thông số gửi cho server khi nhận quest
        QuestGiverName = "Quest Giver", -- Tên NPC
        -- Có thể thêm vị trí cố định của CFrame NPC nếu game ẩn NPC
        -- NpcPosition = Vector3.new(...)
    },
    {
        MinLevel = 15,
        MaxLevel = 29,
        MobName = "Monkey",
        QuestName = "JungleQuest",
        QuestLevel = 1,
        QuestGiverName = "Jungle Quest Giver",
    },
    {
        MinLevel = 30,
        MaxLevel = 39,
        MobName = "Gorilla",
        QuestName = "JungleQuest",
        QuestLevel = 2,
        QuestGiverName = "Jungle Quest Giver",
    }
    -- Sau này có map mới, đảo mới, bạn CHỈ CẦN thêm vào đây, không cần đụng tới code chạy!
}

return MobData
