local QuestCompletionScript = {}


local types = {
	"Get Item",
	"Go Somewhere",
}

function isType(what)
	return function(p)
		return p.type == what
	end
end

-- Script properties are defined here
QuestCompletionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "type", type = "string", options = types, default = "Get Item" },
	{ name = "requiredItem", type = "template", visibleIf=isType("Get Item") },
	{ name = "requiredLocation", type = "template", visibleIf=isType("Go Somewhere") },
	{ name = "onComplete", type = "event" }
}

--This function is called on the server when this entity is created
function QuestCompletionScript:Init()
	if isType("Get Item") then 
		self:GetEntity().inventoryScript.properties.onInventoryUpdated:Listen(self, "HandleInventoryUpdated")
	end
	
	if isType("Go Somewhere") then 
		self:GetEntity().userLocationScript.properties.onSetLocation:Listen(self, "HandleLocationUpdated")
	end
end

function QuestCompletionScript:HandleLocationUpdated(locationId, spawnLocation, locationEntity)
	if locationEntity:GetTemplate() == self.properties.requiredLocation then 
		self.properties.onComplete:Send()
	end
end

function QuestCompletionScript:HandleInventoryUpdated()
	local items = self:GetEntity().inventoryScript.inventory
	for _, item in ipairs(items) do 
		if item.template == self.requiredItem then 
			self.properties.onComplete:Send()
		end
	end
end

return QuestCompletionScript
