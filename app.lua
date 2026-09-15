-- app.lua: Điểm khởi chạy chính — kết nối UI và AutoFarm
local UI = require("UI.main_ui")
local AutoFarm = require("core.auto_farm")

local BotApp = {}

function BotApp.Init()
    print("═══════════════════════════════════════")
    print("  Blox Fruits Auto Farm Bot")
    print("  Khởi chạy hệ thống...")
    print("═══════════════════════════════════════")

    -- Bước 1: Tải giao diện Menu
    UI.Load()

    -- Bước 2: Khởi chạy AutoFarm (chờ lệnh từ UI)
    AutoFarm.Start(UI)

    -- (Mô phỏng: sau 2 giây, người dùng bật Auto Farm trên giao diện)
    task.spawn(function()
        task.wait(2)
        print("[App] Mô phỏng: Người dùng bật Auto Farm...")
        UI.ToggleAutoFarm(true)
    end)
end

-- Chạy bot
BotApp.Init()

return BotApp
