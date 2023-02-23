local PinkMovement = {}

-- Script properties are defined here
PinkMovement.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function PinkMovement:Init()
	self.speed = Vector.New(0,0,0)
end

function PinkMovement:ClientInit()
	self.speed = Vector.New(0,0,0)
end

--This function is called on the server when this entity is created
function PinkMovement:Move(dt, accel, friction, player)

	-- player is the thing we're moving towards
	if not player then
		return
	end
	
	local userPosition = player:GetPosition()
	
	-- lookAt is the direction we want to go
	local lookAt = (userPosition - self:GetEntity():GetPosition()):Normalize()
	lookAt.z = 0

	-- speed is a vector
	-- friction is a scalar
	-- dt is the number of seconds since the last tick
	-- accel is a scalar

	
	self.speed = self.speed + accel * lookAt * dt 
	self.speed = self.speed - (self.speed * friction * dt)

	-- we can't go up or down. 
	local z = self:GetEntity():GetPosition().z
	local newPosition = self:GetEntity():GetPosition() + (self.speed * dt)
	newPosition.z = z
	
	self:GetEntity():SetPosition(newPosition)
	self:GetEntity():SetForward(lookAt)
end

return PinkMovement
