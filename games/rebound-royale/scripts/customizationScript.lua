local CustomizationScript = {}

-- Script properties are defined here
CustomizationScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "requirement", type = "number" },
	{ name = "template", type = "template" },
	{ name = "image", type = "string" }
}

--This function is called on the server when this entity is created
function CustomizationScript:Init()
end

return CustomizationScript
