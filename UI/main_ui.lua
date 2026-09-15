-- UI/main_ui.lua
-- Quản lý trạng thái UI (bật/tắt Auto Farm, v.v.)

local BASE_URL = "https://raw.githubusercontent.com/dubaonhan-droid/blox-fruits/main/"

local UI = {}

-- Lưu trữ trạng thái các tùy chọn của người chơi
UI.Settings = {
    AutoFarm = false
}

function UI.Load()
    print("[UI] Đang tải giao diện...")

    -- Gọi module menu để vẽ giao diện, truyền UI qua tham số (tránh circular require)
    local Menu = loadstring(game:HttpGet(BASE_URL .. "UI/menu.lua"))()
    Menu.Build(UI)
end

-- Hàm bật/tắt Auto Farm — được gọi từ Menu hoặc app.lua
function UI.ToggleAutoFarm(state)
    if state ~= nil then
        UI.Settings.AutoFarm = state
    else
        UI.Settings.AutoFarm = not UI.Settings.AutoFarm
    end
    print("[UI] Auto Farm hiện đang: " .. (UI.Settings.AutoFarm and "BẬT" or "TẮT"))
end

return UI
