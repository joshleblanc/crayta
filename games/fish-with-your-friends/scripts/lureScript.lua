local LureScript = {}

-- Script properties are defined here
LureScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "fishingPower", type = "number", default = 0 }
}

--This function is called on the server when this entity is created
function LureScript:Init()
end

return LureScript
