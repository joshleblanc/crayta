local UserStatsScript = {}

-- Script properties are defined here
UserStatsScript.Properties = {
	-- Example property
	{ name = "kills", type = "number", default = 0, editable = false },
	{ name = "captures", type = "number", default = 0, editable = false },
	{ name = "deaths", type = "number", default = 0, editable = false },
}

--This function is called on the server when this entity is created
function UserStatsScript:Init()
end

function UserStatsScript:AddDeath()
	self.properties.deaths = self.properties.deaths + 1
end

function UserStatsScript:AddCapture()
	self.properties.captures = self.properties.captures + 1 
end

function UserStatsScript:AddKill()
	self.properties.kills = self.properties.kills + 1
end

function UserStatsScript:ResetStats()
	self.properties.kills = 0
	self.properties.captures = 0
	self.properties.deaths = 0
end

return UserStatsScript
