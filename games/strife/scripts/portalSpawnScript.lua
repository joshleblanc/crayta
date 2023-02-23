local PortalSpawnScript = {}

-- Script properties are defined here
PortalSpawnScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "playerTemplate", type = "template" },
	{ name = "onUse", type = "event" },
	{ name = "effects", type = "entity", container = "array" },
	{ name = "owner", type = "number", editable = false },
	{ name = "spawnLocation", type = "entity" },
	{ name = "activatedSound", type = "entity" },
	{ name = "activeLoopSound", type = "entity" }
}

function PortalSpawnScript:Deactivate(id, team)
	if team > 0 then 
		self.properties.effects[team].active = false
		self.properties.owner = 0
		self.properties.activeLoopSound.active = false
	end
end

function PortalSpawnScript:Reset()
	for i=1,#self.properties.effects do 
		self.properties.effects[i].active = false
	end
	self.properties.owner = 0
	self.properties.activeLoopSound.active = false
	self.properties.activatedSound.active = false
end

function PortalSpawnScript:Activate(id, team)
	if team == 0 then 
		self:Reset()
	else 
		self.properties.effects[team].active = true
		self.properties.owner = team
		
		--Fluff Sounds
		self:Schedule(function()
			self.properties.activatedSound.active = true
			Wait(1)
			self.properties.activeLoopSound.active = true
			Wait(2)
			self.properties.activatedSound.active = false
		end)
	end
end

function PortalSpawnScript:HandleTriggerEnter(player)
	if not player:FindScriptProperty("isGhost") then return end 
	
	local user = player:GetUser()
	local team = user:FindScriptProperty("team")
	
	print("Entered portal", team, self.properties.owner)
	
	if team ~= self.properties.owner then
		player:GetUser():SendToScripts("Shout", "This portal doesn't belong to your team!")
		return
	end 
	
	player.GhostSettings:SendToLocal("Disable")
	
	user.spawnUserScript.properties.playerTemplate = self.properties.playerTemplate
	user.spawnUserScript.properties.spawnPoint = self.properties.spawnLocation
	user:SendToScripts("SpawnInternal", false)

	
	self.properties.onUse:Send()
	self:Deactivate()
end

return PortalSpawnScript
