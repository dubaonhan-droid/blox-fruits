-- UI/menu.lua
-- Module vẽ giao diện Menu (GUI) trên màn hình game
-- Dùng Orion Library để tạo UI đẹp, hỗ trợ cả PC và Mobile

local Menu = {}

function Menu.Build(UI_State)
    print("[Menu] Đang vẽ giao diện Menu...")

    -- Load Orion Library (UI cho Roblox, hỗ trợ Mobile)
    local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
    
    -- Tạo cửa sổ chính
    local Window = OrionLib:MakeWindow({
        Name = "🍈 Blox Fruits Auto Farm",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "BloxFruitsBot"
    })

    -- ═══════════════════════════════════════
    -- TAB 1: Farm chính
    -- ═══════════════════════════════════════
    local FarmTab = Window:MakeTab({
        Name = "Main Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    FarmTab:AddToggle({
        Name = "⚔️ Bật Auto Farm Level",
        Default = false,
        Callback = function(Value)
            UI_State.ToggleAutoFarm(Value)
        end
    })

    FarmTab:AddLabel("Bật toggle để bot tự động:")
    FarmTab:AddParagraph("Hướng dẫn", "1. Bật Auto Farm\n2. Bot tự nhận quest theo level\n3. Bay đến bãi farm và đánh quái\n4. Quest xong tự nhận quest mới\n5. Lên level tự chuyển vùng")

    -- ═══════════════════════════════════════
    -- TAB 2: Thông tin
    -- ═══════════════════════════════════════
    local InfoTab = Window:MakeTab({
        Name = "Info",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    InfoTab:AddLabel("📊 Blox Fruits Auto Farm Bot")
    InfoTab:AddParagraph("Credit", "Made by dubaonhan-droid")

    -- Khởi tạo giao diện
    OrionLib:Init()

    print("[Menu] ✅ Giao diện đã hiện trên màn hình!")
end

return Menu
