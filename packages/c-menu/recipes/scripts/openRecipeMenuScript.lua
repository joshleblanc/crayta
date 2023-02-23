local OpenRecipeMenuScript = {}

-- Script properties are defined here
OpenRecipeMenuScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "interactText", type = "text" },
	{ name = "recipeList", type = "string" },
}

--This function is called on the server when this entity is created
function OpenRecipeMenuScript:Init()
end

function OpenRecipeMenuScript:GetInteractPrompt(prompts)
	prompts.interact = self.properties.interactText
end

function OpenRecipeMenuScript:OnInteract(player)
	player.cMenuRecipesScript:OpenForRecipeList(self.properties.recipeList)
end

return OpenRecipeMenuScript
