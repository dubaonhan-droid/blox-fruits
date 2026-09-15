local UI = {}

UI.Settings = {
    AutoFarm = false,
    WeaponType = "Melee", -- Melee, Sword, Blox Fruit
    FastAttack = false
}

function UI.ToggleAutoFarm(state)
    if state ~= nil then
        UI.Settings.AutoFarm = state
    else
        UI.Settings.AutoFarm = not UI.Settings.AutoFarm
    end
    print("[UI] Auto Farm: " .. (UI.Settings.AutoFarm and "BẬT" or "TẮT"))
end

function UI.SetWeaponType(weapon)
    UI.Settings.WeaponType = weapon
    print("[UI] Đã chọn vũ khí: " .. weapon)
end

function UI.ToggleFastAttack(state)
    UI.Settings.FastAttack = state
    print("[UI] Fast Attack: " .. (state and "BẬT" or "TẮT"))
end

return UI
