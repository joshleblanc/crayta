local SpringboardScript = {}

-- Script properties are defined here
SpringboardScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "spring", type = "entity" },
	{ name = "springSound", type = "soundasset" },
	{ name = "platform", type = "entity" },
	{ name = "directionLocator", type = "entity" },
	{ name = "strength", type = "number", default = 2500 }
}

--This function is called on the server when this entity is created
function SpringboardScript:Init()
	self.active = false
	self:Play()
end

function SpringboardScript:OnTriggerEnter(player)
	if self.active then return end 
	
	self:Play(player)
end

function SpringboardScript:Play(player)
	self.active = true
	
	self:Schedule(function()
		self:PlayAnimation()
		self:GetEntity():PlaySound(self.properties.springSound)
		
		local startPosition = self.properties.platform:GetPosition()
		local startRotation = self.properties.platform:GetRotation()
		local downPosition = self.properties.platform:GetPosition()
		downPosition.z = downPosition.z - 50
		
		local topPosition = self.properties.platform:GetPosition()
		topPosition.z = topPosition.z + 75
		 
		self.properties.platform:PlayTimeline(
			0, self.properties.platform:GetPosition(),
			0.075, downPosition, Rotation.Zero,
			0.20, topPosition, startRotation
		)
		
		if player then 
			print("launching player")
			local dir = (self.properties.directionLocator:GetPosition() - self.properties.platform:GetPosition()):Normalize()
			player:Launch(dir * self.properties.strength)
		end
		
		Wait(self.properties.platform:PlayTimeline(
			0, topPosition, startRotation,
			0.50, startPosition
		))
		
		self.active = false
	end)	
end

function SpringboardScript:PlayAnimation()
	self.properties.spring:PlayAnimation("active")
end

return SpringboardScript
