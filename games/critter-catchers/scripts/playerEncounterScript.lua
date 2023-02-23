local PlayerEncounterScript = {}

-- Script properties are defined here
PlayerEncounterScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "isInEncounter", type = "boolean", default = false, editable = false },
}

--This function is called on the server when this entity is created
function PlayerEncounterScript:Init()
end

function PlayerEncounterScript:EnableEncounters(lootTable, minLevel, maxLevel)
	self:DisableEncounters()
	
	self.encounterChanceSchedule = self:Schedule(function()
		local lastPosition
		
		while true do 
			if not self:IsInEncounter() then 
				self:ProcessEncounterChance(lootTable, minLevel, maxLevel)
			end
			
			Wait(1)
		end
	end)
end

function PlayerEncounterScript:DisableEncounters()
	if self.encounterChanceSchedule then 
		self:Cancel(self.encounterChanceSchedule)
	end
end

function PlayerEncounterScript:ProcessEncounterChance(lootTable, minLevel, maxLevel)
	local currentPosition = self:GetEntity():GetPosition()
	
	if not self:ComparePositions(currentPosition, lastPosition) then 
		print("Processing encounter chance", currentPosition, lastPosition, currentPosition == lastPosition)
		local result = lootTable:FindItemByChance()
		
		if result then 
			local level = math.random(minLevel, maxLevel)
			self:StartEncounter(result, level)
		end
	end
	
	lastPosition = currentPosition
end

function PlayerEncounterScript:ComparePositions(a, b)
	if not a and not b then return true end 
	if not a or not b then return false end 
	
	return math.floor(a.x) == math.floor(b.x) and math.floor(a.y) == math.floor(b.y) and math.floor(a.z) == math.floor(b.z)
end

function PlayerEncounterScript:StartEncounter(monster, level)
	assert(not self:IsInEncounter(), "Player is already in an encounter, cannot start another encounter")
	
	print("Start Encounter", monster:GetName())
	self.properties.isInEncounter = true
	
	self:GetEntity().battleScreenScript:StartBattle({
		wildEncounter = true,
		monsters = { 
			{ level = level, template = monster }
		}
	})
end

function PlayerEncounterScript:EndEncounter()
	if not IsServer() then 
		self:SendToServer("EndEncounter")
		return
	end
	
	self:Schedule(function()
		Wait(5)
		self.properties.isInEncounter = false
	end)
end

function PlayerEncounterScript:IsInEncounter()
	return self.properties.isInEncounter
end

return PlayerEncounterScript
