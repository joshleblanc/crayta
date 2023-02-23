local UserInfectionScript = {}

-- Script properties are defined here
UserInfectionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "isInfected", type = "boolean", default = false, editable = false },
	{ name = "spawnPoint", type = "entity" },
	{ name = "respawnTime", type = "number", default = 3 },
	{ name = "survivorTemplate", type = "template" },
	{ name = "infectedTemplate", type = "template" },
}

--This function is called on the server when this entity is created
function UserInfectionScript:Init()
end

function UserInfectionScript:HandleLobbyStart()
	self.properties.isInfected = false
	self:Respawn(self.properties.survivorTemplate)
	self:GetEntity():SendToScripts("SetTeam", 1)
end

function UserInfectionScript:HandleRoundStart(params)
	if GetWorld():GetServerTime() > params.startTime then -- mid round join
		self:Infect()
	end
end

function UserInfectionScript:Respawn(template)
	local player = self:GetEntity():SpawnPlayerWithEffect(template, self.properties.spawnPoint)
	
	player:FindScriptProperty("onDied"):Listen(self, "HandlePlayerDied")
	
	return player
end

function UserInfectionScript:Infect()
	self.properties.isInfected = true
	
	local player = self:GetEntity():GetPlayer()
	
	if player then 
		local pos = self:GetEntity():GetPlayer():GetPosition()
		local rot = self:GetEntity():GetPlayer():GetRotation()
		
		player = self:GetEntity():SpawnPlayer(self.properties.infectedTemplate, pos, rot)
		player:FindScriptProperty("onDied"):Listen(self, "HandlePlayerDied")
	else 
		player = self:Respawn(self.properties.infectedTemplate)
	end
	
	self:GetEntity():SendToScripts("SetTeam", 2)
end

function UserInfectionScript:HandlePlayerDied()
	if self.properties.isInfected then 
		self:GetEntity():GetPlayer():SetAlive(false)
		self:Schedule(function()
			Wait(3)
			self:Respawn(self.properties.infectedTemplate)
		end)
	else 
		self:Infect()
	end
end

return UserInfectionScript
