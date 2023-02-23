local DefaultStartingAnimationScript = {}

-- Script properties are defined here
DefaultStartingAnimationScript.Properties = {
	-- Example property
	{name = "defaultStart", type = "string"},
}

--This function is called on the server when this entity is created
function DefaultStartingAnimationScript:Init()
	self:GetEntity():PlayAnimation(self.properties.defaultStart)
end

return DefaultStartingAnimationScript
