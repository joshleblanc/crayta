local PlayerPosessionsScript = {}

-- Script properties are defined here
PlayerPosessionsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerPosessionsScript:Init()
	self:GetEntity():GetUser().userPosessionsScript:HandlePlayerSpawn(self:GetEntity())
end

return PlayerPosessionsScript
