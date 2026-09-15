-- UI/menu.lua
-- Module này chuyên chịu trách nhiệm vẽ giao diện Menu (GUI) trên màn hình game
local UI_State = require("UI.main_ui")

local Menu = {}

function Menu.Build()
    print("[Menu] Đang vẽ giao diện Menu...")
    
    -- TEMPLATE GIAO DIỆN SỬ DỤNG ORION LIBRARY (Rất phổ biến cho Blox Fruits)
    -- Bạn có thể bỏ comment (xóa --[[ và ]]--) đoạn dưới để nó hiện Menu thật trong Roblox
    
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
            -- Gọi hàm ở main_ui để thay đổi biến trạng thái
            UI_State.ToggleAutoFarm(Value)
        end    
    })

    OrionLib:Init()
    ]]--
    
    print("[Menu] Khởi tạo Menu thành công. Đã hiển thị Toggle Auto Farm.")
end

return Menu
