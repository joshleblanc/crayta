local HeroScript = {}

-- Script properties are defined here
HeroScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "text" },
	{ name = "price", type = "number", editable = false },
	{ name = "description", type = "text" },
	{ name = "forSale", type = "boolean", default = false, editable = false },
	{ name = "purchaseId", type = "string", editable = false },
	{ name = "purchased", type = "boolean", editable = false },
	{ name = "purchaseTrigger", type = "entity" },
	{ name = "weight", type = "number", options = { 
		{ name = "Common", value = 5 },
		{ name = "Uncommon", value = 4 },
		{ name = "Rare", value = 3 },
		{ name = "Exotic", value = 2 },
		{ name = "Legendary", value = 1 }
	}, default = 5 },
	{ name = "owner", type = "entity", editable = false },
	{ name = "id", type = "string", editable = false },
	{ name = "availableId", type = "string", editable = false },
	{ name = "iconUrl", type = "string" },
	{ name = "roomTemplate", type = "template" }
}

local PRICE_MAP = {
	10000,
	5000,
	2500,
	1000,
	500
}

local WEIGHTS = {
	5, 4, 3, 2, 1
}

local RARITY_MAP = {
	"Legendary", "Exotic", "Rare", "Uncommon", "Common"
}

function HeroScript:Init()
	self:AdjustPurchaseTrigger()
	
	self:GetTrigger().onTriggerEnter:Listen(self, "HandleTriggerEnter")
	self:GetTrigger().onTriggerExit:Listen(self, "HandleTriggerExit")
end

function HeroScript:OnRecordUpdated(t, hero)
	if t ~= "heroes" then return end
	if hero._id ~= self.properties.id then return end 
	
	if hero.mia then 
		self:GetEntity():SendToScripts("SetVisibilityOff")
	else
		self:GetEntity():SendToScripts("SetVisibilityOn")
	end
end

function HeroScript:GetTrigger()
	return self.properties.purchaseTrigger:GetChildren()[1]
end

function HeroScript:GetNextWeight(weight)
	for i, w in ipairs(WEIGHTS) do 
		if w == weight then 
			return WEIGHTS[i + 1]
		end
	end
	return nil
end

function HeroScript:GetRarity()
	return RARITY_MAP[self.properties.weight]
end

function HeroScript:GetPrice()
	return PRICE_MAP[self.properties.weight]
end

function HeroScript:SetOwner(owner)
	self.properties.owner = owner
	
	if #self.properties.id == 0 then 
		return
	end
	
	self.properties.owner.documentStoresScript:UseDb("heroes", function(db)
		local hero = db:FindOne({ _id = self.properties.id })
		
		printf("Found hero {1} with id {2}", self:GetEntity():GetName(), self.properties.id)
		
		if hero.mia then 
			self:GetEntity():SendToScripts("SetVisibilityOff")
		else
			self:GetEntity():SendToScripts("SetVisibilityOn")
		end
	end)
end

function HeroScript:GetDb()
	return self.properties.owner.documentStoresScript.heroes
end

function HeroScript:SetId(id)
	self.properties.id = id
end

function HeroScript:SetAvailableId(id)
	self.properties.availableId = id
end

function HeroScript:ToTable() 
	tbl = {
		name = tostring(self.properties.name),
		price = self.properties.price,
		templateName = self:GetEntity():GetTemplate():GetName()
	}
	
	local stats = self:GetEntity():FindAllScripts("statScript")
	
	for _, stat in ipairs(stats) do 
		tbl[stat.properties.statId] = stat.properties.baseLevel
	end
	
	return tbl
end 

function HeroScript:GetBaseStats()
	local data = {}
	local stats = self:GetEntity():FindAllScripts("statScript")
	
	for _, stat in ipairs(stats) do 
		data[stat.properties.statId] = stat.properties.baseLevel
	end
	
	return data
end
function HeroScript:StatWidgetData()
	local stats = self:GetEntity():FindAllScripts("statScript")
	local dataStats = {}
		
	print("Getting stat widget data")
	
	for _, stat in ipairs(stats) do 
		local level = stat.properties.baseLevel
		if #self.properties.id > 0 then 
			level = self.properties.owner.userHeroesScript:GetStatLevel(self.properties.id, stat.properties.statId)
		end
		table.insert(dataStats, {
			name = stat.properties.statName,
			level = level,
			imageUrl = stat.properties.imageUrl
		})
	end
	return dataStats
end

function HeroScript:HandleTriggerEnter(player)
	if player:IsA(Character) then 
		local user = player:GetUser()
		user.purchaseHeroScript:SetHero(self)
	end

end

function HeroScript:HandleTriggerExit(player)
	if player:IsA(Character) then 
		local user = player:GetUser()
	
		user.purchaseHeroScript:UnsetHero()
	end
end

function HeroScript:SetForSale(what)
	self.properties.forSale = what
	self:AdjustPurchaseTrigger()
end

function HeroScript:SetPurchaseId(what)
	self.properties.purchaseId = what
end

function HeroScript:SetPurchased(what)
	self.properties.purchased = what
end

function HeroScript:AdjustPurchaseTrigger()
	self:Schedule(function()
		while not self:GetTrigger() do
			Wait()
		end
		
		if self.properties.forSale then 
			self:GetTrigger().active = true
		else 
			self:GetTrigger().active = false
		end
	end)
	
end

return HeroScript
