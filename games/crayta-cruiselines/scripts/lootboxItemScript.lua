local LootboxItemScript = {}

-- Script properties are defined here
LootboxItemScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "mesh", type = "meshasset" },
	{ name = "name", type = "string" },
	{ name = "id", type = "string" }
}

--This function is called on the server when this entity is created
function LootboxItemScript:Init()
end

return LootboxItemScript
