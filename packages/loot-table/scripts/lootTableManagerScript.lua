local LootTableManagerScript = {}

-- Script properties are defined here
LootTableManagerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function LootTableManagerScript:Init()
	self.lootTables = self:GetEntity():FindAllScripts("lootTableScript")
end

function LootTableManagerScript:ClientInit()
	self:Init()
end

function LootTableManagerScript:FindLootTable(name)
	for _, t in ipairs(self.lootTables) do 
		if name == t.properties.name then 
			return t
		end
	end
	
	return nil
end

return LootTableManagerScript
