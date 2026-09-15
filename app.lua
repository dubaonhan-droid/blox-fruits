-- app.lua: Module chính kết nối toàn bộ bot
local UI = require("UI.main_ui")

local StarterIsland = {
    Bandit = require("island.starter_island.bandit"),
    Trainee = require("island.starter_island.trainee")
}

local Jungle = {
    Monkey = require("island.jungle.monkey"),
    Gorilla = require("island.jungle.gorilla")
}

-- Cấu hình Level -> Quái vật
local LevelConfig = {
    { min = 1,  max = 14,   farmModule = StarterIsland.Bandit, name = "Bandit" },
    { min = 15, max = 29,   farmModule = Jungle.Monkey,        name = "Monkey" },
    { min = 30, max = 9999, farmModule = Jungle.Gorilla,       name = "Gorilla" }
}

local BotApp = {}

-- Hàm giả lập lấy cấp độ của người chơi
-- Trong thực tế Roblox sẽ tương tự: return game:GetService("Players").LocalPlayer.Data.Level.Value
function BotApp.GetPlayerLevel()
    return 20 -- Giả lập đang ở cấp 20 (Sẽ farm Monkey)
end

-- Hàm tự động phân tích level và trả về con quái cần đánh
function BotApp.GetFarmModuleByLevel(level)
    for _, config in ipairs(LevelConfig) do
        if level >= config.min and level <= config.max then
            return config.farmModule, config.name
        end
    end
    return nil, nil
end

-- Vòng lặp farm tự động chạy dưới nền
function BotApp.AutoFarmLoop()
    -- Sử dụng task.spawn (API chuẩn của Roblox) để không block luồng chính
    task.spawn(function()
        while true do
            if UI.Settings.AutoFarm then
                local currentLevel = BotApp.GetPlayerLevel()
                local farmModule, targetName = BotApp.GetFarmModuleByLevel(currentLevel)
                
                if farmModule then
                    print("[AutoFarm] Đang ở Level " .. currentLevel .. ". Tự động farm: " .. targetName)
                    farmModule.Farm()
                else
                    print("[AutoFarm] Không tìm thấy bãi farm phù hợp cho cấp: " .. currentLevel)
                end
            end
            
            -- Nghỉ ngơi 1 giây trước khi lặp lại để game không bị crash do overload
            task.wait(1)
        end
    end)
end

function BotApp.Init()
    print("Khởi chạy Blox Fruits Auto Farm Bot...")
    UI.Load()
    
    -- Khởi chạy vòng lặp nghe theo lệnh Auto Farm
    BotApp.AutoFarmLoop()

    -- (Đoạn này chỉ là mô phỏng việc người dùng tích vô Menu Auto Farm sau 2 giây)
    task.spawn(function()
        task.wait(2)
        UI.ToggleAutoFarm(true)
    end)
end

-- Chạy bot
BotApp.Init()

return BotApp
