local GiveItemScript = {}

-- Script properties are defined here
GiveItemScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "template", type = "template" },
	{ name = "quantity", type = "number", default = 1 },
}

--This function is called on the server when this entity is created
function GiveItemScript:Init()
end

function GiveItemScript:GiveItem(user)
	local items = user.inventoryScript:FindItemForTemplateOrEmptyItem(self.properties.template)
	local diff = self.properties.quantity - items.count 
	if diff > 0 then 
		user:SendToScripts("AddToInventory", self.properties.template, diff)
	end
end

return GiveItemScript