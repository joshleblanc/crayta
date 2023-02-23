local Floaty = {}

-- Script properties are defined here
Floaty.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},4
	{ name = "friction", type = "number" },
	{ name = "accel", type = "number" },
	{ name = "trigger", type = "entity" },
	{ name = "target", type = "entity", visible = false  },
	{ name = "score", type = "number" },
	{ name = "distance", type = "number" },
	{ name = "zoomSoundController", type = "entity" }
}

function Floaty:ClientInit()
	self.speed = Vector.New(0, 0, 0)
	self.friction = self.properties.friction
	self.accel = self.properties.accel
	self.timeAlive = 0
end
function Floaty:OnTick()
	self:GetTarget()
end

function Floaty:CheckPlayers()
	local user = GetWorld():GetLocalUser()
	local player = user:GetPlayer()
	
	if not player then return end 
	
	local userPosition = player:GetPosition()
		
	if(Vector.Distance(self:GetEntity():GetPosition(), userPosition) < self.properties.distance) then
		self.properties.zoomSoundController:SendToScripts("PlayZoomSound", self:GetEntity())
		player:FindScript("playerController"):SendToScript("AddScore", self.properties.score)
	end
	
	if(self.properties.trigger:IsOverlapping(player)) then
		self.properties.zoomSoundController:SendToScripts("PlayHitSound", self:GetEntity())
		player:GetUser():SendToServer("Kill")
	end
end

function Floaty:GetTarget()
	local needsTarget = true
	if self.properties.target then
		if self.properties.target:IsAlive() and self.properties.target:FindScriptProperty("playing") then
			needsTarget = false
		end
	end
	if needsTarget then
		local possibilities = {}
		GetWorld():ForEachUser(function(user) 
			local player = user:GetPlayer()
			if player and player:IsAlive() and player:FindScriptProperty("playing") then
				table.insert(possibilities, player)
			end
		end)
		
		self.properties.target = possibilities[math.random(1, #possibilities)]
	else
		return self.properties.target
	end
end

function Floaty:ClientOnTick(dt)
	self:GetEntity():SendToScripts("Move", dt, self.accel, self.friction, self.properties.target)
	self:CheckPlayers()
end

return Floaty
