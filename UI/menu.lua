-- UI/menu.lua
-- Module vẽ giao diện Menu (GUI) trên màn hình game
-- Dùng Rayfield Library — hỗ trợ cả PC và Mobile

local Menu = {}

function Menu.Build(UI_State)
    print("[Menu] Đang tải Rayfield UI Library...")

    -- Load Rayfield Library (hỗ trợ Mobile, đang hoạt động 2026)
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    -- Tạo cửa sổ chính
    local Window = Rayfield:CreateWindow({
        Name = "🍈 Blox Fruits Auto Farm",
        LoadingTitle = "Blox Fruits Bot",
        LoadingSubtitle = "by dubaonhan-droid",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "BloxFruitsBot",
            FileName = "Config"
        },
        KeySystem = false -- Tắt key system (không cần nhập key)
    })

    -- ═══════════════════════════════════════
    -- TAB 1: Farm chính
    -- ═══════════════════════════════════════
    local FarmTab = Window:CreateTab("⚔️ Main Farm", "swords")

    FarmTab:CreateToggle({
        Name = "Bật Auto Farm Level",
        CurrentValue = false,
        Flag = "AutoFarmToggle",
        Callback = function(Value)
            UI_State.ToggleAutoFarm(Value)
        end
    })

    FarmTab:CreateLabel("Bật toggle → Bot tự farm theo level")

    FarmTab:CreateParagraph({
        Title = "📖 Hướng dẫn",
        Content = "1. Bật Auto Farm\n2. Bot tự nhận quest theo level\n3. Bay đến bãi farm và đánh quái\n4. Quest xong → nhận quest mới\n5. Lên level → tự chuyển vùng"
    })

    -- ═══════════════════════════════════════
    -- TAB 2: Thông tin
    -- ═══════════════════════════════════════
    local InfoTab = Window:CreateTab("ℹ️ Info", "info")

    InfoTab:CreateLabel("Blox Fruits Auto Farm Bot")

    InfoTab:CreateParagraph({
        Title = "Credit",
        Content = "Made by dubaonhan-droid\nUI: Rayfield Library"
    })

    print("[Menu] ✅ Giao diện đã hiện trên màn hình!")
end

return Menu
