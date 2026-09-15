-- UI/menu.lua
-- Module vẽ giao diện Menu (GUI) trên màn hình game
-- KHÔNG require("UI.main_ui") ở đây để tránh circular require
-- Thay vào đó, nhận UI_State qua tham số Build()

local Menu = {}

function Menu.Build(UI_State)
    print("[Menu] Đang vẽ giao diện Menu...")

    -- TEMPLATE GIAO DIỆN SỬ DỤNG ORION LIBRARY (Rất phổ biến cho Blox Fruits)
    -- Bỏ comment (xóa --[[ và ]]--) đoạn dưới để hiện Menu thật trong Roblox

    --[[
    local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
    local Window = OrionLib:MakeWindow({
        Name = "Blox Fruits Auto Farm",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "BloxFruitsBot"
    })

    local FarmTab = Window:MakeTab({
        Name = "Main Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    FarmTab:AddToggle({
        Name = "Bật Auto Farm Level",
        Default = false,
        Callback = function(Value)
            UI_State.ToggleAutoFarm(Value)
        end
    })

    OrionLib:Init()
    ]]--

    print("[Menu] ✅ Khởi tạo Menu thành công.")
end

return Menu
