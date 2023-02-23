local CMenuInventoryScript = {}

-- Script properties are defined here
CMenuInventoryScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onUseItem", type = "event" },
}

--This function is called on the server when this entity is created
function CMenuInventoryScript:Init()
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	self.cache = GetWorld():FindScript("entityCacheScript")
	
	self.inventoryScript = self:GetEntity().inventoryScript or self:GetEntity():GetUser().inventoryScript
	self:CountLastInventory()
		
	self:HandleInventoryUpdated()
	self.inventoryScript.properties.onInventoryUpdated:Listen(self, "HandleInventoryUpdated")

	
	local player = self.user:GetPlayer()
	self.notificationsScript = self.user.cMenuNotificationsScript
	if player and not self.notificationsScript then 
		self.notificationsScript = player.cMenuNotificationsScript
	end
end

function CMenuInventoryScript:LocalInit()
	self.menuOption = self:GetEntity().cMenuScript:FindOption("Inventory")

	self.menuOption.properties.onClose:Listen(self, "HandleWidgetClose")
	
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
end

function CMenuInventoryScript:HandleWidgetClose()
	print("Inventory widget was closed")
	if IsServer() then 
		self:SendToLocal("HandleWidgetClose")
		return
	end
	
	self:GetEntity():GetUser():SendToScripts("Respond", false)
end

function CMenuInventoryScript:GetWidget()
	return self.menuOption.widget
end

function CMenuInventoryScript:GetFlag(template, flag)
	if not template then 
		return false
	end
	
	return template:FindScriptProperty(flag)
end

function CMenuInventoryScript:UseItem(templateName)
	if not IsServer() then 
		self:SendToServer("UseItem", templateName)
		return
	end
	
	local entity
	if self.cache then 
		entity = self.cache:FindEntityByTemplate(templateName)
	end
	
	if not entity then 
		local template = GetWorld():FindTemplate(templateName)
		entity = GetWorld():Spawn(template, Vector.Zero, Rotation.Zero)
	end
	
	entity.cMenuInventoryItemSpecScript:OnUse(self.user)
	
	self.properties.onUseItem:Send(templateName)
end

function CMenuInventoryScript:DropItem(templateName)
	if not IsServer() then 
		self:SendToServer("DropItem", templateName)
		return
	end
	
	local template = GetWorld():FindTemplate(templateName)
	
	local count = self.user.inventoryScript:GetTemplateCount(template)
	self.user.inventoryScript:RemoveTemplate(template, count)
end

function CMenuInventoryScript:ExamineItem(text)
	self.user:SendToScripts("AddNotification", text)
end

function CMenuInventoryScript:CountLastInventory()
	self.lastInventory = {}
	for _, item in ipairs(self.inventoryScript.inventory) do
		if item and item.template then 
			self.lastInventory[item.template] = ((self.lastInventory[item.template] or {}).count or 0) + item.count
		end
	end
end

function CMenuInventoryScript:FindNewItems()
	local itemCount = {}
	
	for _, item in ipairs(self.inventoryScript.inventory) do 
		if item and item.template then 
			itemCount[item.template] = ((itemCount[item.template] or {}).count or 0) + item.count
		end
	end
	
	for template, count in pairs(itemCount) do 
		if self.lastInventory[template] and self.lastInventory[template] < count or not self.lastInventory[template] then 
			self.notificationsScript:AddNotification({
				imageUrl = self:GetIcon(template),
				quantity = count - (self.lastInventory[template] or 0),
				title = "Item Received",
				subtitle = self:GetName(template),
				accent = "#3438da"
			})
		end
	end
	
	self:CountLastInventory()
end

function CMenuInventoryScript:HandleInventoryUpdated(inventory, currencies)
	if IsServer() then
		self:FindNewItems()
		self:SendToLocal("HandleInventoryUpdated", self.inventoryScript.inventory, self.inventoryScript.currencies)
		return
	end
	
	local inventoryView = {}
	for index, inventoryItem in ipairs(inventory) do
		inventoryView[index] = { 
			templateName = inventoryItem.template and inventoryItem.template:GetName(),
			name = self:GetName(inventoryItem.template), 
			count = inventoryItem.count, 
			description = self:GetText(inventoryItem.template, "description"),
			icon = self:GetIcon(inventoryItem.template),
			usable = self:GetFlag(inventoryItem.template, "usable"),
			examinable = self:GetFlag(inventoryItem.template, "examinable"),
			examineText = self:GetText(inventoryItem.template, "examineText"),
			droppable = self:GetFlag(inventoryItem.template, "droppable")
		}
	end
	local currenciesView = {}
	for name, currency in pairs(currencies) do
		table.insert(currenciesView, { 
			name = self:GetName(currency.template), 
			icon = self:GetIcon(currency.template),
			count = currency.count, 
		})
	end
	
	self:GetWidget().js.data.inventory = inventoryView
	self:GetWidget().js.data.currencies = currenciesView
end

function CMenuInventoryScript:GetName(template)
	if not template then
		return ""
	end

	return template:FindScriptProperty("friendlyName") or template:GetName()
end

function CMenuInventoryScript:GetText(template, key)
	if not template then
		return ""
	end
	
	local val = template:FindScriptProperty(key)
	
	return val or ""
end

function CMenuInventoryScript:GetIcon(template)
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

return CMenuInventoryScript
