local RecipeListScript = {}

-- Script properties are defined here
RecipeListScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "string" },
}

--This function is called on the server when this entity is created
function RecipeListScript:Init()
end

return RecipeListScript
