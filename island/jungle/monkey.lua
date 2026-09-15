-- island/jungle/monkey.lua
local MonkeyFarm = {}

function MonkeyFarm.GetQuest()
    print("[Monkey] Đang nhận nhiệm vụ Monkey...")
end

function MonkeyFarm.GoToMob()
    print("[Monkey] Đang bay (teleport) đến bãi quái Monkey...")
end

function MonkeyFarm.Attack()
    print("[Monkey] Đang tấn công Monkey...")
end

function MonkeyFarm.Farm()
    MonkeyFarm.GetQuest()
    MonkeyFarm.GoToMob()
    MonkeyFarm.Attack()
end

return MonkeyFarm
