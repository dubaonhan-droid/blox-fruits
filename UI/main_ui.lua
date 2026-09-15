-- UI/main_ui.lua
-- File này giờ KHÔNG load file khác nữa (app.lua lo hết)
-- Chỉ chứa logic quản lý trạng thái UI

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

return UI
