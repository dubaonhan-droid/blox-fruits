-- app.lua: Điểm khởi chạy chính
-- Load TẤT CẢ module ở đây (không nested loadstring) để tránh lỗi trên mobile

local BASE_URL = "https://raw.githubusercontent.com/dubaonhan-droid/blox-fruits/main/"

-- ═══════════════════════════════════════
-- BƯỚC 0: Load tất cả module với error handling
-- ═══════════════════════════════════════
local function SafeLoad(name, url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then
        print("[Loader] ✅ Đã load: " .. name)
        return result
    else
        warn("[Loader] ❌ Lỗi load " .. name .. ": " .. tostring(result))
        return nil
    end
end

-- Load từng module một (KHÔNG để file tự load file khác)
local MobData  = SafeLoad("MobData",  BASE_URL .. "config/mob_data.lua")
local AutoFarm = SafeLoad("AutoFarm", BASE_URL .. "core/auto_farm.lua")
local Menu     = SafeLoad("Menu",     BASE_URL .. "UI/menu.lua")

-- ═══════════════════════════════════════
-- UI STATE (đặt trực tiếp ở đây thay vì file riêng)
-- ═══════════════════════════════════════
local UI = {}
UI.Settings = {
    AutoFarm = false
}

function UI.ToggleAutoFarm(state)
    if state ~= nil then
        UI.Settings.AutoFarm = state
    else
        UI.Settings.AutoFarm = not UI.Settings.AutoFarm
    end
    print("[UI] Auto Farm: " .. (UI.Settings.AutoFarm and "BẬT" or "TẮT"))
end

-- ═══════════════════════════════════════
-- KHỞI CHẠY
-- ═══════════════════════════════════════
local BotApp = {}

function BotApp.Init()
    print("═══════════════════════════════════════")
    print("  🍈 Blox Fruits Auto Farm Bot")
    print("  Khởi chạy hệ thống...")
    print("═══════════════════════════════════════")

    -- Bước 1: Hiển thị Menu GUI
    if Menu then
        Menu.Build(UI)
    else
        warn("[App] ⚠️ Không load được Menu! Tự bật Auto Farm sau 3 giây...")
        task.spawn(function()
            task.wait(3)
            UI.ToggleAutoFarm(true)
        end)
    end

    -- Bước 2: Khởi chạy AutoFarm
    if AutoFarm then
        AutoFarm.SetMobData(MobData)
        AutoFarm.Start(UI)
    else
        warn("[App] ❌ Không load được AutoFarm!")
    end
end

BotApp.Init()

return BotApp
