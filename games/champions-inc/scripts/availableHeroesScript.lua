local AvailableHeroesScript = {}

-- Script properties are defined here
AvailableHeroesScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "numOptions", type = "number", default = 5 },
}

--This function is called on the server when this entity is created
function AvailableHeroesScript:Init()
end

function AvailableHeroesScript:PurchaseHero(heroScript)
	local availableHeroesDB = self:GetEntity().documentStoresScript.availableHeroes
	
	availableHeroesDB:UpdateOne({ _id = heroScript.properties.availableId }, {
		_set = {
			purchased = true
		}
	})
end

function AvailableHeroesScript:GetCurrentSelection(force)
	force = force or false
	
	local db = self:GetEntity().documentStoresScript:GetDb("default")
	local doc = db:FindOne() 
	
	if not doc then return {} end 
	
	local availableHeroesDB = self:GetEntity().documentStoresScript.availableHeroes
	
	local day = GetWorld():GetUTCTime()
	day = math.floor(day / 86400)

	local options = {}
	
	if not doc.lastSelectionDay or doc.lastSelectionDay < day or force then 
		for i=1,self.properties.numOptions do 
			local option = self:GetEntity().lootTableManagerScript:FindLootTable("All Heroes"):FindItemByChance()
			table.insert(options, {
				templateName = option:GetName(),
				purchased = false
			})
		end
		
		db:UpdateOne({}, {
			_set = {
				lastSelectionDay = day
			}
		})
		
		availableHeroesDB:DeleteMany()

		options = availableHeroesDB:InsertMany(options)
	else
		options = availableHeroesDB:Find()
	end
	
	return options
end

return AvailableHeroesScript
