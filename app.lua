-- app.lua: Điểm khởi chạy chính — kết nối UI và AutoFarm
-- Dùng loadstring + HttpGet thay cho require (chạy từ GitHub raw)

local BASE_URL = "https://raw.githubusercontent.com/dubaonhan-droid/blox-fruits/main/"

local UI = loadstring(game:HttpGet(BASE_URL .. "UI/main_ui.lua"))()
local AutoFarm = loadstring(game:HttpGet(BASE_URL .. "core/auto_farm.lua"))()

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
