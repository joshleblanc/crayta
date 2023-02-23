local RecipeResultScript = {}

-- Script properties are defined here
RecipeResultScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "parentId", type = "string" },
	{ name = "type", type = "string", options = { "lootTable", "template" }, default = "template", group = "Result" },
	{ name = "template", type = "template", visibleIf=function(p) return p.type == "template" end, group = "Result" },
	{ name = "lootTableName", type = "string", visibleIf=function(p) return p.type == "lootTable" end, group = "Result" },
	{ name = "count", type = "number", default = 1, group = "Result" },
}

--This function is called on the server when this entity is created
function RecipeResultScript:Init()
end

function RecipeResultScript:Create()
	if not IsServer() then 
		self:SendToServer("Create")
		return
	end
	
	if self.properties.type == "template" then 
		self:CreateTemplate()
	elseif self.properties.type == "lootTableName" then 
		self:CreateLootTable()
	end
end

function RecipeResultScript:CreateTemplate()
	self:GetEntity():SendXPEvent("create-recipe", { recipeId = self.properties.parentId, result = self.properties.template:GetName() })
	self:GetEntity().inventoryScript:AddToInventory(self.properties.template, self.properties.count)
end

function RecipeResultScript:CreateLootTable()
	local lootTable = self:GetEntity().lootTableManager:FindLootTable(self.properties.lootTableName)
	local item = lootTable:FindItemByChance()
	
	self:GetEntity():SendXPEvent("create-recipe", { recipeId = self.properties.parentId, result = item:GetTemplate():GetName() })
	
	self:GetEntity().inventoryScript:AddToInventory(item, self.properties.count)
end

return RecipeResultScript
