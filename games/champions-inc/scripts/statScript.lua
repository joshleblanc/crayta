local StatScript = {}

-- Script properties are defined here
StatScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "statName", type = "text" },
	{ name = "statId", type = "string" },
	{ name = "baseLevel", type = "number" },
	{ name = "imageUrl", type = "string" }
}

--This function is called on the server when this entity is created
function StatScript:Init()
end

return StatScript
