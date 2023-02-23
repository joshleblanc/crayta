local ReadyStatusScript = {}

-- Script properties are defined here
ReadyStatusScript.Properties = {
	-- Example property
	{ name = "readyMesh", type = "entity" },
	{ name = "notReadyMesh", type = "entity" },
	{ name = "readyMessage", type = "text" },
	{ name = "notReadyMessage", type = "text" },
	{ name = "gameController", type = "entity" },
	{ name = "readySound", type = "soundasset" },
	{ name = "unreadySound", type = "soundasset" }
}

--This function is called on the server when this entity is created
function ReadyStatusScript:Init()
	self.users = {}
	self:NotReady()
	
	self.countdownSchedule = nil
	
	self.properties.gameController.game.properties.onGameEnd:Listen(self, "OnGameEnd")
end

function ReadyStatusScript:OnTriggerEnter(player)
	local user = player:GetUser()
	table.insert(self.users, user)
	
	print("Number of users ready: " .. #self.users)
	
	player:GetUser().localSoundScript:PlaySound2D(self.properties.readySound)
	
	
	if self.properties.gameController.game.properties.running then
		self:ShoutAllUsers("A game is in progress. Wait until they're finished!")
	else
		GetWorld():ForEachUser(function(u)
			if u == user then
				u:SendToScripts("AddNotification", "You're readied up!")
			else
				u:SendToScripts("AddNotification", self.properties.readyMessage, user:GetUsername())		
			end
		end)
		
		if #self.users == 1 then
			self:Ready()
		end
	end	
end

function ReadyStatusScript:OnGameEnd()
	if #self.users > 0 then 
		self:Ready()
	end
end

function ReadyStatusScript:OnTriggerExit(player)
	
	local user = player:GetUser()
	local ind = nil
	for k, v in ipairs(self.users) do
		if v == user then
			ind = k
		end
	end
	
	player:GetUser().localSoundScript:PlaySound2D(self.properties.unreadySound)
	
	if ind then 
		table.remove(self.users, ind)
	end
		
	if #self.users == 0 then 
		self:NotReady()
	end
	
	if player:FindScriptProperty("playing") then
		return
	end
	
	if self.properties.gameController.game.properties.running then 
		return 
	end
	
	GetWorld():ForEachUser(function(u)
		if u == user then
			u:SendToScripts("AddNotification", "You're no longer readied up")
		else
			u:SendToScripts("AddNotification", self.properties.notReadyMessage, user:GetUsername())		
		end
	end)
end

function ReadyStatusScript:ShoutAllUsers(msg)
	GetWorld():ForEachUser(function(u)
		u:SendToScripts("Shout", msg)
	end)
end

function ReadyStatusScript:Ready()
	self.properties.readyMesh.visible = true
	self.properties.notReadyMesh.visible = false
	
	local time = 10 
	if #GetWorld():GetUsers() == 1 then 
		time = 3
	end
	
	self:ShoutAllUsers(FormatString("Game will begin in {1} seconds. Get to the ready room!", time))
	
	if self.countdownSchedule then
		self:Cancel(self.countdownSchedule)
	end
	
	self.countdownSchedule = self:Schedule(function()
		for i=1,time do 
			Wait(1)
			self:ShoutAllUsers("Game will begin in " .. (time - i) .. " seconds. Get to the ready room!")
		end
		
		print("Starting game")
		
		self.properties.gameController.game.properties.running = true
		
		GetWorld():FindScript("spawner"):SendToScript("Start")
		--GetWorld():FindScript("playerController"):SendToScripts("Start")

		print("Number of users to start: " .. #self.users)
		
		GetWorld():ForEachUser(function(user)
			for k, v in ipairs(self.users) do
				if v == user then
					print("Starting game for " .. tostring(user:GetUsername()))
					user:GetPlayer():SendToScripts("Start")
					user:SendToScripts("Start")
					user:GetPlayer():SetPosition(self.properties.gameController.game.properties.gameSpawn:GetPosition())
				end
			end	
		end)
	end)
end

function ReadyStatusScript:NotReady()
	self.properties.readyMesh.visible = false
	self.properties.notReadyMesh.visible = true
	
	if self.countdownSchedule then
		self:Cancel(self.countdownSchedule)
	end
	
	if self.properties.gameController.game.properties.running then
		return 
	end
	
	GetWorld():ForEachUser(function(u)
		u:SendToScripts("Shout", "Game countdown has been cancelled")
	end)
end

return ReadyStatusScript
