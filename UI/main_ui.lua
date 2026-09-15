-- UI/main_ui.lua
local UI = {}

-- Lưu trữ trạng thái các tuỳ chọn của người chơi
UI.Settings = {
    AutoFarm = false
}

function UI.Load()
    print("Đang tải dữ liệu trạng thái cho UI...")
    
    -- Gọi module menu riêng biệt để vẽ giao diện
    local Menu = require("UI.menu")
    Menu.Build()
end

-- Hàm này được gọi khi người dùng bấm vào nút bật/tắt Auto Farm trên màn hình
function UI.ToggleAutoFarm(state)
    if state ~= nil then
        UI.Settings.AutoFarm = state
    else
        UI.Settings.AutoFarm = not UI.Settings.AutoFarm
    end
    print("[UI] Auto Farm hiện đang: " .. (UI.Settings.AutoFarm and "BẬT" or "TẮT"))
end

return UI
