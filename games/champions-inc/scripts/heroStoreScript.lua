local HeroStoreScript = {}

-- Script properties are defined here
HeroStoreScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "heroSpawns", type = "entity" },
}

--This function is called on the server when this entity is created
function HeroStoreScript:Init()
	self.entities = {}
	
	self.originalPosition = self.properties.heroSpawns:GetPosition()
	
	self:GetEntity().onDestroy:Listen(self, "DespawnHeroes")
end

function HeroStoreScript:DespawnHeroes()
	for _, entity in ipairs(self.entities) do 
		entity:Destroy()
	end
	
	self.entities = {}
end

function HeroStoreScript:RerollHeroes()
	self:SpawnHeroes(true)
end

function HeroStoreScript:ShouldSpawnDefaults()
	return not self.owner.userHeroesScript:HasAnyHeroes()
end

function HeroStoreScript:FindCommon()
	local options = self.owner.availableHeroesScript:GetCurrentSelection(true)
	if self:ShouldSpawnDefaults() then 
		local hasCommon = false
		for _, o in ipairs(options) do 
			local template = GetWorld():FindTemplate(o.templateName)
			local weight = template:FindScriptProperty("weight") 
			if weight == 5 then 
				hasCommon = true
			end
		end
		if hasCommon then 
			return options
		else
			return self:FindCommon()
		end
	end
end

function HeroStoreScript:SpawnHeroes(force)
	self:DespawnHeroes()
	
	self.entities = {}
	
	local options
	if self:ShouldSpawnDefaults() then 
		options = self:FindCommon()
	else
		options = self.owner.availableHeroesScript:GetCurrentSelection(force)
	end

	print("Spawning store heroes", #options)
		
	local spawnPointIndex = 1
	local spawnPoints = self.properties.heroSpawns:GetChildren()
	
	local spacing = 250
	for i, option in ipairs(options) do 
		local templateName = option.templateName
		local template = GetWorld():FindTemplate(templateName)
		local entity = GetWorld():Spawn(template, Vector.Zero, Rotation.Zero)
		
		entity:AttachTo(spawnPoints[spawnPointIndex])
		spawnPointIndex = spawnPointIndex + 1
		
		entity:SendToScripts("SetOwner", self.owner)
		entity:SendToScripts("SetForSale", true)
		entity:SendToScripts("SetPurchased", option.purchased)
		entity:SendToScripts("SetAvailableId", option._id)
		
		table.insert(self.entities, entity)	
	end
	self.properties.heroSpawns:SetPosition(self.originalPosition)
	
--	local spawnPosition = self.properties.heroSpawns:GetPosition()
--	spawnPosition.x = spawnPosition.x - ((spacing * #options) / 2)
--	self.properties.heroSpawns:SetPosition(spawnPosition)
end

function HeroStoreScript:HandleLocationSpawn(owner)
	self.owner = owner
	self:SpawnHeroes(false)
end

return HeroStoreScript
