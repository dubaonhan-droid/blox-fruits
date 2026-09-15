-- island/jungle/gorilla.lua
local GorillaFarm = {}

function GorillaFarm.GetQuest()
    print("[Gorilla] Đang nhận nhiệm vụ Gorilla...")
end

function GorillaFarm.GoToMob()
    print("[Gorilla] Đang bay (teleport) đến bãi quái Gorilla...")
end

function GorillaFarm.Attack()
    print("[Gorilla] Đang tấn công Gorilla...")
end

function GorillaFarm.Farm()
    GorillaFarm.GetQuest()
    GorillaFarm.GoToMob()
    GorillaFarm.Attack()
end

return GorillaFarm
