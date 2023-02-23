local PlatformMinigameScript = {}

-- Script properties are defined here
PlatformMinigameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "respawn", type = "entity" }
}

--This function is called on the server when this entity is created
function PlatformMinigameScript:Init()
end

function PlatformMinigameScript:HandleCollision(player)
	self:Schedule(function()
		player:SetAlive(false)
		Wait(3)
		player:GetUser():SpawnPlayerWithEffect(player:GetTemplate(), self.properties.respawn)
	end)
end

return PlatformMinigameScript
