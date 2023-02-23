local LootTableScript = {}

-- Script properties are defined here
LootTableScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "string", tooltip = "This name is printed when printing probabilities when debug is on" },
	{ name = "debug", type = "boolean", tooltip = "Show probabilities on init" }, 
	{ name = "noDropWeight", type = "number", tooltip = "The weight that nothing will drop", default = 0, min = 0 }
}

--This function is called on the server when this entity is created
function LootTableScript:Init()
	local all = self:GetEntity():FindAllScripts("lootTableItemScript")
	self.allItems = {}
	
	for _, item in ipairs(all) do 
		if item.properties.lootTableName == self.properties.name or #item.properties.lootTableName == 0 then
			table.insert(self.allItems, item)
		end
	end
	
	self.possibilities = {}
	local possibilitiesSum = self.properties.noDropWeight
	
	-- Sum weights and store possible items
	-- Remove 0-chance items
	for _, possibility in ipairs(self.allItems) do 
		possibility:Init()
		if possibility.properties.weight > 0 then 
			possibilitiesSum = possibilitiesSum + possibility.properties.weight
			table.insert(self.possibilities, possibility)
		end
	end

	-- Calculate the probability of picking this item (between 0 and 1)
	for _, possibility in ipairs(self.possibilities) do 
		possibility.properties.chance = possibility.properties.weight / possibilitiesSum
	end
	self.noDropPossibility = self.properties.noDropWeight / possibilitiesSum
	
	if self.properties.debug then 
		self:PrintProbabilities()
	end

	-- Create a data structure we can query for an item later
	self.itemMap = {}
	local sum = 0
	for _, possibility in ipairs(self.possibilities) do 
		sum = sum + possibility.properties.chance
		table.insert(self.itemMap, { possibility.properties.item, sum })
	end
	
	if self.properties.noDropWeight > 0 then 
		table.insert(self.itemMap, { nil, sum + self.noDropPossibility })
	end
end

function LootTableScript:GetName()
	if self.properties.name.length ~= "" then 
		return self.properties.name
	else
		return self:GetEntity():GetName()
	end
end

function LootTableScript:PrintProbabilities()
	self:Debug("Probabilities for {1}", self:GetName())
	for _, p in ipairs(self.allItems) do 
		self:Debug("{1}: {2}", p.properties.item:GetName(), (p.properties.chance * 100) .. "%")
	end
	
	if self.properties.noDropWeight > 0 then 
		self:Debug("{1}: {2}", "No Drop", (self.noDropPossibility * 100) .. "%")
	end
	
end

function LootTableScript:FindItemByChance()
	local roll = math.random()
	
	for _, possibility in ipairs(self.itemMap) do 
		if possibility[2] > roll then 
		
			if self.properties.debug then 
				if possibility[1] then 
					self:Debug("{1}: selected {2}", self:GetName(), possibility[1]:GetName())
				else 
					self:Debug("{1}: selected {2}", self:GetName(), "No Drop")
				end
			end

			return possibility[1]
		end
	end

	return nil
end

function LootTableScript:Debug(msg, ...)
	printf("LootTableScript: " .. msg, ...)
end

return LootTableScript
