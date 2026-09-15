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
    local MainTab = Window:CreateTab("Main Farm", 4483362458)

    local FarmSection = MainTab:CreateSection("Cài đặt chung")

    MainTab:CreateToggle({
        Name = "Bật Auto Farm Level",
        CurrentValue = false,
        Flag = "AutoFarmToggle",
        Callback = function(Value)
            UI_State.ToggleAutoFarm(Value)
        end,
    })

    local WeaponSection = MainTab:CreateSection("Vũ Khí & Combat")

    MainTab:CreateDropdown({
        Name = "Chọn Vũ Khí Farm",
        Options = {"Melee", "Sword", "Blox Fruit"},
        CurrentOption = {"Melee"},
        MultipleOptions = false,
        Flag = "WeaponDropdown",
        Callback = function(Option)
            UI_State.SetWeaponType(Option[1])
        end,
    })

    MainTab:CreateToggle({
        Name = "Fast Attack (Đánh Nhanh)",
        CurrentValue = false,
        Flag = "FastAttackToggle",
        Callback = function(Value)
            UI_State.ToggleFastAttack(Value)
        end,
    })

    local ToolSection = MainTab:CreateSection("Công cụ hỗ trợ (Fix lỗi khác đảo)")

    MainTab:CreateButton({
        Name = "In Tọa Độ Hiện Tại (Copy vào mob_data.lua)",
        Callback = function()
            local pos = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position
            local posString = string.format("Vector3.new(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
            print("==================================")
            print("TỌA ĐỘ CỦA BẠN LÀ:")
            print(posString)
            print("Hãy copy dòng trên dán vào QuestNpcPosition hoặc FarmPosition")
            print("==================================")
            
            -- Tự động copy vào clipboard nếu exploit hỗ trợ
            if setclipboard then
                setclipboard(posString)
                print("Đã tự động copy vào Clipboard!")
            end
        end,
    })

    local InfoSection = MainTab:CreateSection("Hướng dẫn")

    MainTab:CreateLabel("Bật toggle → Bot tự farm theo level")

    MainTab:CreateParagraph({
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
