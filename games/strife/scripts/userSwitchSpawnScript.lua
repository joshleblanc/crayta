local UserSwitchSpawnScript = {}

-- Script properties are defined here
UserSwitchSpawnScript.Properties = {
	-- Example property
	{ name = "ghostTemplate", type = "template" },
	{ name = "livingTemplate", type = "template" },
	{ name = "lobbyTemplate", type = "template" }
}

function UserSwitchSpawnScript:SetGhostTemplate()
	print("Setting ghost template")
	self:GetEntity().spawnUserScript.properties.spawnPoint = self:GetEntity().spawnUserScript:FindSpawn()
	self:GetEntity().spawnUserScript.properties.playerTemplate = self.properties.ghostTemplate
end

function UserSwitchSpawnScript:SetLivingTemplate()
	print("Setting living template")
	self:GetEntity().spawnUserScript.properties.playerTemplate = self.properties.livingTemplate
end

function UserSwitchSpawnScript:SetLobbyTemplate()
	print("Setting lobby template")
	self:GetEntity().spawnUserScript.properties.playerTemplate = self.properties.lobbyTemplate
end

return UserSwitchSpawnScript
