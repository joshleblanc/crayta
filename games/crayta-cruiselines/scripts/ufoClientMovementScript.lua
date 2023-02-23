local UfoClientMovementScript = {}

-- Script properties are defined here
UfoClientMovementScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UfoClientMovementScript:ClientInit()
	self.oldPos = self:GetEntity():GetRelativePosition()
	self.oldRot = self:GetEntity():GetRelativeRotation()
	self.newPos = self:GetEntity():GetRelativePosition() + Vector.New(0,0,500)
	self:Move()
end

function UfoClientMovementScript:Move()
	self:GetEntity():PlayRelativeTimelineLoop({
	0, self.oldPos, Rotation.Zero,
	30, self.newPos, Rotation.New(0,180,0),"EaseInOut",
	60, self.oldPos, Rotation.New(0,360,0),"EaseInOut",
	})
end


return UfoClientMovementScript
