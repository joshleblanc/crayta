SpawnUserScript = {}

SpawnUserScript.Properties = {
	{ name = "spawnPoint", type = "entity", },
	{ name = "playerTemplate", type = "template", },
	{ name = "spawnSound", type = "soundasset", },

	{ name = "onUserDied", type = "event"},
	
	{ name = "respawnActive", type = "boolean", default = true, },
	{ name = "respawnDelayTime", type = "number", default = 8.0, visibleIf = function(p) return p.respawnActive end, },
	
	{ name = "spawnOnLogin", type = "boolean", default = false, tooltip = "Set this to true to spawn a player using this on login, rather than wait for a game to do lobbies, or whatever", },
}

function SpawnUserScript:Init()
	Print("SpawnUserScript:Init ", self:GetEntity():GetName())
	self.spawnScripts = GetWorld():FindAllScripts("spawnScript")
	self.initialSpawnPoint = self.properties.spawnPoint -- we will reset this when calling Spawn() in case its been set to a checkpoint mid round
end

function SpawnUserScript:SetSpawn(spawn)
	self.properties.spawnPoint = spawn
end

function SpawnUserScript:GetSpawn()
	return self.properties.spawnPoint
end

function SpawnUserScript:FindSpawn()

	local hasPlayerNear = function(spawn)
		local minDistance = 100
		local playerNear = false
		GetWorld():ForEachUser(
			function(testUser)
				if 
					testUser ~= self:GetEntity() and 
					testUser:GetPlayer() and 
					testUser:GetPlayer():IsAlive() and 
					Vector.Distance(testUser:GetPlayer():GetPosition(), spawn:GetPosition()) < minDistance then
					playerNear = true
				end
			end
		)
		return playerNear
	end

	-- score all of the spawnScript's, score is random 0-1 + 
	-- 1 for a nearby player, +2 for wrong team and +4 for wrong isLobby
	-- so all the random ones will be before all the ones with nearby players
	-- which will be before all the ones of the incorrect team, etc..
	local scores = {}
	local team = self:GetEntity():FindScriptProperty("team")
	for _, spawnScript in ipairs(self.spawnScripts) do
		local spawn = spawnScript:GetEntity()
		local score = 
			-- random 0-1 score to randomly select
			-- from any that have otherwise the same score
			math.random() + 
			-- score +1 for a player is near
			((hasPlayerNear(spawn)) and 1 or 0) + 
			-- score +2 for being incorrect team
			((team ~= 0 and team ~= spawnScript.properties.team) and 2 or 0)  +
			-- score +4 for being incorrect lobby state
			((spawnScript.properties.isLobby ~= self.isLobby) and 4 or 0)
		table.insert(scores, {spawn = spawn, score = score})
	end
	
	if #scores == 0 then
		return nil
	end
	
	table.sort(scores, function(s1, s2) return s1.score < s2.score end)

	--[[print("SpawnUserScript: Scores for each spawn:")
	for scoreIndex, score in ipairs(scores) do
		print("  ", scoreIndex, score.spawn:GetName(), score.score)
	end]]

	return scores[1].spawn
end

-- if our player died we just respawn a few seconds later if we're still active then
function SpawnUserScript:OnPlayerDied(player, fromEntity)
	
	self.properties.onUserDied:Send(self:GetEntity(), fromEntity)
	
	if not self.respawnTask then
		self.respawnTask = self:Schedule(
			function()
				Wait(self.properties.respawnDelayTime)
				if self.properties.respawnActive then
					player:Destroy()
					self:SpawnInternal(self.isLobby)
				end
			end
		)
	end
end

function SpawnUserScript:Spawn(params)
	print("Spawning", params.spawn)
	self.properties.spawnPoint = self.initialSpawnPoint
	self.properties.respawnActive = params.respawnActive or false
	if params.spawn then
		if params.alwaysRespawn or self:GetEntity():GetPlayer() == nil or not self:GetEntity():GetPlayer():IsAlive() then
			self:SpawnInternal(params.isLobby or false)		
		end
	end
end

function SpawnUserScript:SpawnInternal(isLobby)
	
	self.isLobby = isLobby

	-- cancel any respawn...
	if self.respawnTask then
		self:Cancel(self.respawnTask)
		self.respawnTask = nil
	end
	
	local player
	local spawn = self.properties.spawnPoint or self:FindSpawn()
	if spawn then
		print("SpawnUserScript: Spawn at " .. spawn:GetName())
		spawn:GetParent():SendToScripts("ActivateSpawnPoint", self:GetEntity())
		player = self:GetEntity():SpawnPlayer(self.properties.playerTemplate, spawn)
	else
		print("SpawnUserScript: Spawn anywhere")
		player = self:GetEntity():SpawnPlayer(self.properties.playerTemplate)
	end
	
	local onPlayerDied = player:FindScriptProperty("onDied")
	if onPlayerDied then
		onPlayerDied:Listen(self, "OnPlayerDied")		
	end

	if self.properties.spawnSound then
		self:GetEntity():PlaySound(self.properties.spawnSound)
	end

end

function SpawnUserScript:Despawn(params)
	self.properties.respawnActive = false
	if self:GetEntity():GetPlayer() then
		self:GetEntity():GetPlayer():Destroy()
	end
	if params.camera then
		self:GetEntity():SetCamera(params.camera)
	end
end

-- if we set the spawnOnLogin flag we don't wait for a game or anything global to spawn us
function SpawnUserScript:OnUserLogin(user)
	if self.properties.spawnOnLogin and user == self:GetEntity() then
		self:SpawnInternal(false)
	end
end
	
return SpawnUserScript