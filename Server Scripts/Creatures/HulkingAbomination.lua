
local zombieMinionID = 90000
local timePassed = {}

function spawnZombies(pUnit, number, id)
	--local map = pUnit:GetMap()
	for i=1,number do
		local x = pUnit:GetX() + math.random(-15, 15)
		local y = pUnit:GetY() + math.random(-15, 15)
		pUnit:SpawnCreature(id, x, y, pUnit:GetZ() + 1--[[map:GetHeight(x, y)]], 0, 6, 5000)
	end
end

local function ZombieTicker(eventId, delay, repeats, pUnit)
	--local map = pUnit:GetMap()
	local t = pUnit:GetNearObjects(40, 0, zombieMinionID)
	for _,v in pairs(t) do
		if v and v:IsStopped() and v:GetFaction() == 17 and not v:IsInCombat() and pUnit:GetDistance2d(v) < 50 then
			local x = pUnit:GetX() + math.random(-15, 15)
			local y = pUnit:GetY() + math.random(-15, 15)
			v:MoveTo(0, x, y, pUnit:GetZ() + 1--[[map:GetHeight(x, y)]])
		end
	end
	local currentTime = timePassed[tostring(pUnit:GetGUID())]
	if not currentTime then
		currentTime = 0
	end
	if currentTime > 10000 then
		currentTime = 0
		spawnZombies(pUnit, 1, zombieMinionID)
	else
		currentTime = currentTime + delay
	end
	--pUnit:SendUnitSay(tostring(currentTime) .. " | " .. tostring(delay) .. " | " .. tostring(pUnit:GetGUID()), 0)
	timePassed[tostring(pUnit:GetGUID())] = currentTime
	pUnit:RegisterEvent(ZombieTicker, math.random(1000, 3000), 1)
end

local function HookAPlayer(eventId, delay, repeats, pUnit)
	if pUnit:IsInCombat() then
		local target = pUnit:GetAITarget(0)
		if target then
			pUnit:CastSpell(target, 71140, false)
		end
	end
end

local function ZombieMaster(event, pUnit, extra)
	if event == 1 then -- on combat
		local t = pUnit:GetNearObjects(40, 0, zombieMinionID)
		local target = pUnit:GetAITarget(1)
		if target then
			for _,v in pairs(t) do
				if v then
					v:AttackStart(target)
				end
			end
		end
		spawnZombies(pUnit, 2, zombieMinionID)
	elseif event == 2 then -- leave combat
		--pUnit:RemoveEvents()
	elseif event == 3 then -- target died
		spawnZombies(pUnit, 2, zombieMinionID)
	elseif event == 4 then -- died
		pUnit:RemoveEvents()
	elseif event == 5 then -- spawned
		timePassed[tostring(pUnit:GetGUID())] = 0
		pUnit:RegisterEvent(ZombieTicker, 1000, 1)
		pUnit:RegisterEvent(HookAPlayer, 8000, 0)
	end
end

for i=1,5 do
	RegisterCreatureEvent(90001, i, ZombieMaster)
end
i = nil

---------------------------
---------------------------
---------------------------

local function LoseHealth(eventId, delay, repeats, pUnit)
	pUnit:CastSpell(pUnit, 90004, true) -- DAMAGE SELF
end

local function SetHostile(eventId, delay, repeats, pUnit)
	pUnit:SetFaction(17)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0) -- attackable, targetable
end

local function SetDisplay(eventId, delay, repeats, pUnit)
	pUnit:SetDisplayId(24991 + math.random(1, 7))
end

local function SpawnFromGround(eventId, delay, repeats, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 0) -- above ground
	pUnit:RegisterEvent(SetHostile, 4000, 1)
end

local function ZombieMinion(event, pUnit, extra)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE + UNIT_FIELD_FLAG_UNATTACKABLE)
	pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 9) -- underground
	pUnit:RegisterEvent(SpawnFromGround, 2000, 1)
	pUnit:RegisterEvent(SetDisplay, 1000, 1)
	pUnit:RegisterEvent(LoseHealth, 1000, 0)
end

RegisterCreatureEvent(zombieMinionID, 5, ZombieMinion)

--[[
        CREATURE_EVENT_ON_ENTER_COMBAT                    = 1,  // (event, creature, target) - Can return true to stop normal action
        CREATURE_EVENT_ON_LEAVE_COMBAT                    = 2,  // (event, creature) - Can return true to stop normal action
        CREATURE_EVENT_ON_TARGET_DIED                     = 3,  // (event, creature, victim) - Can return true to stop normal action
        CREATURE_EVENT_ON_DIED                            = 4,  // (event, creature, killer) - Can return true to stop normal action
        CREATURE_EVENT_ON_SPAWN                           = 5,  // (event, creature) - Can return true to stop normal action
]]
