local SealScript = {}

-- Script properties are defined here
SealScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "text" },
	{ name = "ballValue", type = "number", default = 12 }, -- in pokemon gen 1, a great ball had a value of 8
	{ name = "maxRoll", type = "number", default = 255 }, -- ultra ball = 150, great ball = 200
}

--This function is called on the server when this entity is created
function SealScript:Init()
end

function SealScript:Capture(user)
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "Capture", user)
		return
	end
	
	local player = user:GetPlayer()
	local battle = player.battleScreenScript
	local mon = battle:GetOppCurrentMonster()
	
	if not battle.opponent.wildEncounter then 
		user:SendToScripts("AddNotification", "You can't seal someone else's monster!")
		return
	end
	
	local n = math.random(0, 255)
	
	print("n", n, mon.properties.catchRate)
	-- n should also subtract the status effects, but we don't have any yet
	local breaksFree = n > mon.properties.catchRate
	
	if not breaksFree then 
		local m = math.random(1, 255)

	
		local maxHp = mon:GetMaxHp()
		local hp = mon:GetHp()
		
		local f = math.floor((maxHp * 255 * 4) / (hp * self.properties.ballValue))
		f = math.min(f, 255)
		f = math.max(f, 0)
		
		print("m", m, f)
		
		breaksFree = f < m
	end
	
	local numShakes = 4
	
	local messages = { "You throw out a monster seal!" }
	
	if breaksFree then 
		local d = math.floor((mon.properties.catchRate * 100) / self.properties.ballValue)
		if d < 255 then 
			local x = math.floor((d * f) / 255)
			if x < 10 then 
				numShakes = 0
				table.insert(messages, "You missed completely!")
			elseif x < 30 then 
				numShakes = 1
				table.insert(messages, "The seal shakes once...")
			elseif x < 70 then	
				numShakes = 2
				table.insert(messages, "The seal shakes once...")
				table.insert(messages, "The seal shakes twice...")
			else
				numShakes = 3 
				table.insert(messages, "The seal shakes once...")
				table.insert(messages, "The seal shakes twice...")
				table.insert(messages, "The seal shakes three times...")
			end
		else 
			numShakes = 3
			table.insert(messages, "The seal shakes once...")
			table.insert(messages, "The seal shakes twice...")
			table.insert(messages, "The seal shakes three times...")
		end
		table.insert(messages, "The monster broke free of the seal!")
		battle:SealFailure(messages)
	else
		table.insert(messages, "The seal shakes once...")
		table.insert(messages, "The seal shakes twice...")
		table.insert(messages, "The seal shakes three times...")
		table.insert(messages, "The seal shakes four times...")
		table.insert(messages, "Monster has been sealed!")
		battle:SealSuccess(messages)
	end
	user.inventoryScript:SendToServer("RemoveTemplate", self:GetEntity():GetTemplate(), 1)

end

return SealScript
