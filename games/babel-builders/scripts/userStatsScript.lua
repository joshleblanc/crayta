local UserStatsScript = {}

-- Script properties are defined here
UserStatsScript.Properties = {
	-- Example property
	{ name = "speed", type = "number", default = 1 },
	{ name = "strength", type = "number", default = 1 }
}

--This function is called on the server when this entity is created
function UserStatsScript:Init()
end

function UserStatsScript:Assign()
	local player = self:GetEntity():GetPlayer()
	
	if not player:IsA(Character) then return end 
	if not player:IsValid() then return end 
	if not IsServer() then 
		self:SendToServer("Assign") 
		return
	end
	
	print("Assigning stats", self.properties.speed)
	
	player.speedMultiplier = self.properties.speed
end

function UserStatsScript:Add(stat, percent)
	if not IsServer() then
		self:SendToServer("Add", stat, percent)
		return
	end
	
	self.properties[stat] = self.properties[stat] + (percent / 100)
	
	self:Assign()
end

function UserStatsScript:Reset(key)
	if not IsServer() then
		self:SendToServer("Reset", key)
		return
	end
	
	self.properties[key] = 1
end

return UserStatsScript
