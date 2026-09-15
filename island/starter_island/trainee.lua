-- island/starter_island/trainee.lua
local TraineeFarm = {}

function TraineeFarm.GetQuest()
    print("[Trainee] Đang nhận nhiệm vụ Trainee...")
end

function TraineeFarm.GoToMob()
    print("[Trainee] Đang bay (teleport) đến bãi quái Trainee...")
end

function TraineeFarm.Attack()
    print("[Trainee] Đang tấn công Trainee...")
end

function TraineeFarm.Farm()
    TraineeFarm.GetQuest()
    TraineeFarm.GoToMob()
    TraineeFarm.Attack()
end

return TraineeFarm
