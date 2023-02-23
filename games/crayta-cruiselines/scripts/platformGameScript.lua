local PlatformGameScript = {}

-- Script properties are defined here
PlatformGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "platforms", type = "entity" },
	{ name = "trigger", type = "entity" },
	{ name = "resetLocator", type = "entity" },
	{ name = "blockers", type = "entity", container = "array" },
	{ name = "walls", type = "entity"  },
	{ name = "deathTrigger", type = "entity" },
	{ name = "outOfBoundsTriggers", type = "entity", container = "array" },
	{ name = "running", type = "boolean", default = false, editable = false }
}

--This function is called on the server when this entity is created
function PlatformGameScript:Init()
	self.rows = self.properties.platforms:GetChildren()
end

function PlatformGameScript:Activate(event)
	self.event = event
	if not self.properties.running then
		self.properties.running = true
		self:Start()
	end
end

function PlatformGameScript:Deactivate()
	self.event = nil
	if self.properties.running then
		self.properties.running = false
		self:End()
	end
end

function PlatformGameScript:ResetPlayer(player)
	self:Schedule(function()
		player:SetAlive(false)
		Wait(3)
		player:SetPosition(self.properties.resetLocator:GetPosition())
		player:SetAlive(true)
	end)
end

function PlatformGameScript:End()
	self.properties.deathTrigger.active = false 
	
	for _, row in ipairs(self.rows) do
		local platforms = row:GetChildren()
		for _, platform in ipairs(platforms) do
			platform:SendToScripts("End")
		end
	end
	
	for i=1,#self.properties.blockers do 
		self.properties.blockers[i]:SendToScripts("Open")
	end
	
	for _, wall in ipairs(self.properties.walls:GetChildren()) do
		wall.collisionEnabled = false
	end
end

function PlatformGameScript:Reward(player)
	if not self.properties.running then return end
	if not self.event then return end 
	
	self.event:RewardParticipation(player)
end

function PlatformGameScript:HandleTriggerEnter(player)
	player.jumpHeightMultiplier = 0.75
	player.canSprint = false
end

function PlatformGameScript:HandleTriggerExit(player)
	player.jumpHeightMultiplier = 1
	player.canSprint = true
end

function PlatformGameScript:Start()
	self.properties.deathTrigger.active = true 
	
	for i=1,#self.properties.outOfBoundsTriggers do
		self.properties.outOfBoundsTriggers[i]:SendToScripts("RemovePlayers", self.properties.resetLocator)
	end
	
	for i=1,#self.properties.blockers do 
		self.properties.blockers[i]:SendToScripts("Close")
	end
	
	for _, wall in ipairs(self.properties.walls:GetChildren()) do
		wall.collisionEnabled = true
	end

	for _, row in ipairs(self.rows) do
		local platforms = row:GetChildren()
		for _, platform in ipairs(platforms) do
			platform:SendToScripts("Start")
		end
		local index = math.random(1, #platforms)
		platforms[index]:SendToScripts("SetSafe")
	end
end

return PlatformGameScript
