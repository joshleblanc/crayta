local FireFlyScript = {}

-- Script properties are defined here
FireFlyScript.Properties = {
	-- Example property
	{name = "lightSource", type = "entity"},
	{name = "soundSource", type = "entity"},
}

--This function is called on the server when this entity is created
function FireFlyScript:Init()
end

function FireFlyScript:Active()
	self:GetEntity().visible = true
end

return FireFlyScript
