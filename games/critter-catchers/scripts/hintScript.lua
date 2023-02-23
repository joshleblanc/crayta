local HintScript = {}

-- Script properties are defined here
HintScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "questId", type = "string" },
}

--This function is called on the server when this entity is created
function HintScript:Init()
end

return HintScript
