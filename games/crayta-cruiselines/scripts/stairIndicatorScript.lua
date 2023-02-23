local StairIndicatorScript = {}

-- Script properties are defined here
StairIndicatorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "floor", type = "number", default = 1 }
}

--This function is called on the server when this entity is created
function StairIndicatorScript:Init()
end

return StairIndicatorScript
