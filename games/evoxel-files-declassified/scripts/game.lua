local Game = {}

-- Script properties are defined here
Game.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "gameSpawn", type = "entity" },
	{ name = "spookySounds", type = "soundasset", container = "array" },
	{ name = "running", type = "boolean", editable = false },
	{ name = "onGameEnd", type = "event" },
	{ name = "onGameStart", type = "event" }
}

function Game:OnTick() 
	local result = math.random()
	if result < 0.001 then
		local sound = self.properties.spookySounds[math.random(1, #self.properties.spookySounds)]
		self:GetEntity():PlaySound2D(sound)
	end
	
	local done = true
	GetWorld():ForEachUser(function(user) 
		local player = user:GetPlayer()
		if player and player:FindScriptProperty("playing") then
			done = false
		end
	end)
	if done and self.properties.running then
		GetWorld():FindScript("spawner"):SendToScript("Stop")
		self.properties.running = false
		self.properties.onGameEnd:Send()
	end	
end

function Game:Start(entity) 
	if not IsServer() then
		return
	end
	
	if self.properties.running then
		entity:FindScript("dialogScript"):SendToScript("Wait")
		return
	end
	self.properties.running = true
	
	GetWorld():FindScript("spawner"):SendToScript("Start")
	--GetWorld():FindScript("playerController"):SendToScripts("Start")

	
	print("Game Start", entity:GetUser():GetUsername())
	GetWorld():ForEachUser(function(user) 
		user:GetPlayer():SendToScripts("Start")
		user:SendToScripts("Start")
		user:GetPlayer():SetPosition(self.properties.gameSpawn:GetPosition())
	end)
	
end

return Game
