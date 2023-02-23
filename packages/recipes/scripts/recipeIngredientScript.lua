local RecipeIngredientScript = {}

-- Script properties are defined here
RecipeIngredientScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "parentId", type = "string" },
	{ name = "template", type = "template" },
	{ name = "count", type = "number", default = 1 },
}

function RecipeIngredientScript:ToTable()
	return {
		templateName = self.properties.template:GetName(),
		count = self.properties.count,
		parentId = self.properties.parentId
	}
end

return RecipeIngredientScript
