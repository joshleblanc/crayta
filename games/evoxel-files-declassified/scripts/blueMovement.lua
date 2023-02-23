local BlueMovement = {}

-- Script properties are defined here
BlueMovement.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created

function BlueMovement:Initialize()
	self.speed = Vector.New(0,0,0)
	self.target = self:GetEntity():GetPosition() * -1
	self.target.z = 50
end

function BlueMovement:Init()
	self:Initialize()
end

function BlueMovement:ClientInit()
	self:Initialize()
end

function BlueMovement:Move(dt, accel, friction, player)
	if not player then
		return
	end
	local userPosition = self.target
	local lookAt = (userPosition - self:GetEntity():GetPosition()):Normalize()
	lookAt.z = 0
	
	local z = self.speed.z
	
	self.speed = self.speed + (accel * lookAt * dt)
	self.speed = self.speed - (self.speed * friction * dt)
	self.speed.z = z
	
	self:GetEntity():SetPosition(self:GetEntity():GetPosition() + self.speed * dt)
	self:GetEntity():SetForward(lookAt)
	
	if Vector.Distance(self:GetEntity():GetPosition(), userPosition) < 50 then
		self.target = self.target * -1
		self.target.z = 50
	end
end

return BlueMovement
