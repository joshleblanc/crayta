local UserRecipesScript = {}

-- Script properties are defined here
UserRecipesScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserRecipesScript:LocalInit()
	self.recipes = self:GetEntity():FindAllScripts("recipeScript")
	self.results = self:GetEntity():FindAllScripts("recipeResultScript")
	self.ingredients = self:GetEntity():FindAllScripts("recipeIngredientScript")
	
	local recipes = {}
	for _, recipe in ipairs(self.recipes) do 
		recipes[recipe.properties.id] = recipe
	end
	
	for _, ingredient in ipairs(self.ingredients) do 
		local parent = recipes[ingredient.properties.parentId]
		if parent then 
			parent:AddIngredient(ingredient)
		end
	end
	
	for _, result in ipairs(self.results) do 
		local parent = recipes[result.properties.parentId]
		if parent then 
			parent:AddResult(result)
		end
	end
end

function UserRecipesScript:FindRecipe(items, recipeList)
	recipeList = recipeList or ""
	
	local possibleRecipes = { unpack(self.recipes) }
	
	print("Checking if valid recipe", #possibleRecipes, items, recipeList, recipeList and #recipeList)
	for i = #possibleRecipes,1,-1 do
		local recipe = possibleRecipes[i]
		if recipeList ~= recipe.properties.recipeList then 
			table.remove(possibleRecipes, i)
		else
			for templateName, item in pairs(items) do 
				if not recipe:IsIngredient(templateName, item.count) then 
					table.remove(possibleRecipes, i)
				end
			end
		end
	end

	if #possibleRecipes > 1 then 
		return false
	end
	
	if #possibleRecipes == 0 then 
		return false
	end
	
	return possibleRecipes[1]
end

function UserRecipesScript:IsValidRecipe(items, recipeList) 
	if self:FindRecipe(items, recipeList) then 
		return true
	else
		return false
	end
end

return UserRecipesScript
