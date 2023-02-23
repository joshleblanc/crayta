local CMenuRecipesScript = {}

-- Script properties are defined here
CMenuRecipesScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function CMenuRecipesScript:Init()
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	self.inventoryScript = self.user.inventoryScript
	self:HandleInventoryUpdated()
	self.inventoryScript.properties.onInventoryUpdated:Listen(self, "HandleInventoryUpdated")
end

function CMenuRecipesScript:LocalInit()
	self.menuOption = self:GetEntity().cMenuScript:FindOption("Recipes")
	self.selectedItems = {}
	
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	self.inventoryScript = self.user.inventoryScript
	
	self:GetWidget().js.data.selectedItems = self.selectedItems
end

function CMenuRecipesScript:CreateRecipe()
	local recipe = self.user.userRecipesScript:FindRecipe(self.selectedItems, self.recipeList)
	recipe:Create()
	
	self.selectedItems = {}
	self:GetWidget().js.data.selectedItems = self.selectedItems
	self:SendToServer("HandleInventoryUpdated")
	
	self:GetWidget().js.data.isValidRecipe = false
end

function CMenuRecipesScript:OpenForRecipeList(list)
	if IsServer() then 
		self:SendToLocal("OpenForRecipeList", list)
		return
	end
	
	self.recipeList = list
	self.menuOption:ShowMenuOption()
end

function CMenuRecipesScript:Close()
	if IsServer() then 
		self:SendToLocal("Close")
		return
	end
	
	self.recipeList = nil
	self.menuOption:HideMenuOption()
end

function CMenuRecipesScript:HandleOpen()
	if IsServer() then 
		self:SendToLocal("HandleOpen")
		return
	end
	
	self.selectedItems = {}
	self:GetWidget().js.data.selectedItems = self.selectedItems
	self:SendToServer("HandleInventoryUpdated")
end

function CMenuRecipesScript:GetName(template)
	if not template then
		return ""
	end

	return template:FindScriptProperty("friendlyName") or template:GetName()
end


function CMenuRecipesScript:GetWidget()
	return self.menuOption.widget
end

function CMenuRecipesScript:GetText(template, key)
	if not template then
		return ""
	end
	
	local val = template:FindScriptProperty(key)
	
	return val or ""
end

function CMenuRecipesScript:GetIcon(template)
	if not template then
		return ""
	end
		
	local iconProperty = template:FindScriptProperty("iconUrl")
	
	if iconProperty and #iconProperty > 0 then 
		return iconProperty
	end
	
	local iconAsset = template:FindScriptProperty("iconAsset")
		
	if iconAsset then
		return iconAsset:GetIcon()
	else 
		return ""
	end
end


function CMenuRecipesScript:HandleInventoryUpdated(inventory)
	if IsServer() then 
		self:SendToLocal("HandleInventoryUpdated", self.inventoryScript.inventory)
		return
	end
	
	local inventoryView = {}
	for index, inventoryItem in ipairs(inventory) do
		local templateName = inventoryItem.template and inventoryItem.template:GetName()
		local selectedItem = self.selectedItems[templateName] or { count = 0 }
		local count = inventoryItem.count - selectedItem.count
		inventoryView[index] = { 
			templateName = templateName,
			name = self:GetName(inventoryItem.template), 
			count = inventoryItem.count - selectedItem.count,
			description = self:GetText(inventoryItem.template, "description"),
			icon = self:GetIcon(inventoryItem.template),
		}
		
	end
	
	self:GetWidget().js.data.inventory = inventoryView
end

function CMenuRecipesScript:SelectItem(templateName)
	self.selectedItems[templateName] = self.selectedItems[templateName] or { count = 0 }
	self.selectedItems[templateName].count = self.selectedItems[templateName].count + 1
	
	self:GetWidget().js.data.selectedItems = self.selectedItems
	self:SendToServer("HandleInventoryUpdated")
	
	self:GetWidget().js.data.isValidRecipe = self.user.userRecipesScript:IsValidRecipe(self.selectedItems, self.recipeList)
end

function CMenuRecipesScript:RemoveItem(templateName)
	local item = self.selectedItems[templateName]
	if not item then return end
	
	item.count = item.count - 1
	
	if item.count == 0 then 
		self.selectedItems[templateName] = nil
	end 
	
	self:GetWidget().js.data.selectedItems = self.selectedItems
	self:SendToServer("HandleInventoryUpdated")
	
	self:GetWidget().js.data.isValidRecipe = self.user.userRecipesScript:IsValidRecipe(self.selectedItems)
end

return CMenuRecipesScript
