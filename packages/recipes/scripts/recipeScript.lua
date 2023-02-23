local RecipeScript = {}

-- Script properties are defined here
RecipeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" },
	{ name = "recipeList", type = "string", tooltip = "Optional" },
}

--This function is called on the server when this entity is created
function RecipeScript:LocalInit()
	self.ingredients = self.ingredients or {}
	self.results = self.results or {}
end

function RecipeScript:IsIngredient(templateName, count)
	print("Checking", #self.ingredients)
	for _, ingredient in ipairs(self.ingredients) do 
		print("Checking", ingredient.properties.template:GetName(), templateName, ingredient.properties.count, count)
		if ingredient.properties.template:GetName() == templateName and count >= ingredient.properties.count then
			return true
		end
	end
	
	return false
end

function RecipeScript:Create()
	for _, ingredient in ipairs(self.ingredients) do 
		self:GetEntity().inventoryScript:SendToServer("RemoveTemplate", ingredient.properties.template, ingredient.properties.count)
	end
	
	for _, result in ipairs(self.results) do 
		self:GetEntity():SendToScripts("Shout", FormatString("Created: {1}", result.properties.template:FindScriptProperty("friendlyName")))
		result:Create()
	end
end

function RecipeScript:AddIngredient(ingredient)
	self.ingredients = self.ingredients or {}
	table.insert(self.ingredients, ingredient)
end

function RecipeScript:AddResult(result)
	self.results = self.resuts or {}
	table.insert(self.results, result)
end

function RecipeScript:ToTable()
	local ingredients = {}
	
	for _, ingredient in ipairs(self.ingredients) do 
		table.insert(ingredients, ingredient:ToTable())
	end
	
	return {
		id = self.properties.id,
		ingredients = ingredients,
	}
end

return RecipeScript
