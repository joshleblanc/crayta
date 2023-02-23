local UserGhostScript = {}

-- Script properties are defined here
UserGhostScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "ghostTemplate", type = "template" }
}

--This function is called on the server when this entity is created
function UserGhostScript:Init()
end

function UserGhostScript:HandleUserDied()
	print("Handling user died")
	self:GetEntity().spawnUserScript.properties.spawnPoint = self:GetEntity().spawnUserScript:FindSpawn()
	self:GetEntity().spawnUserScript.properties.playerTemplate = self.properties.ghostTemplate
end



return UserGhostScript
