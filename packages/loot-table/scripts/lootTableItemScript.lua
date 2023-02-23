local LootTableItemScript = {}

-- Script properties are defined here
LootTableItemScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "item", type = "template" },
	{ name = "weight", type = "number" },
	{ name = "chance", type = "number", editable = false },
	{ name = "lootTableName", type = "string", tooltip = "Set this to the name of the loot table it's associated with if you have more than one loot table on an entity" }
}

--This function is called on the server when this entity is created
function LootTableItemScript:Init()
	local weightOverride = self.properties.item:FindScriptProperty("weight") 
	
	if weightOverride then 
		self.properties.weight = weightOverride
	end
end

return LootTableItemScript
