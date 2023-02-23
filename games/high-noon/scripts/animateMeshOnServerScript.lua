local AnimateMeshOnServerScript = {}

-- Script properties are defined here
AnimateMeshOnServerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "animationName", type = "string" }
}

--This function is called on the server when this entity is created
function AnimateMeshOnServerScript:Init()
	self:GetEntity():PlayAnimationLooping(self.properties.animationName)
end

return AnimateMeshOnServerScript
