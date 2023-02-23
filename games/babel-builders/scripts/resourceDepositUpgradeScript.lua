local ResourceDepositUpgradeScript = {}

-- Script properties are defined here
ResourceDepositUpgradeScript.Properties = {
	-- Example property
	{ name = "level", type = "number" },
	{ name = "wood", type = "number" },
	{ name = "stone", type = "number" },
	{ name = "template", type = "template" },
	{ name = "locator", type = "entity" },
	{ name = "stat", type = "string", options = { "speed", "strength" } },
	{ name = "statPercent", type = "number", default = 1 }
}

--This function is called on the server when this entity is created
function ResourceDepositUpgradeScript:Init()
end

return ResourceDepositUpgradeScript
