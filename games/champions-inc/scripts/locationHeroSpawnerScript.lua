local LocationHeroSpawnerScript = {}

-- Script properties are defined here
LocationHeroSpawnerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "entryPoints", type = "entity", container = "array" }
}

--This function is called on the server when this entity is created
function LocationHeroSpawnerScript:Init()
	self.id = self:GetEntity().locationScript.properties.id
	self.heroes = {}
end

function LocationHeroSpawnerScript:CleanupHeroes()
	local newData = {}
	
	for _, hero in ipairs(self.heroes) do 
		if Entity.IsValid(hero) then 
			table.insert(newData, hero)
		end
	end
	
	self.heroes = newData
end

function LocationHeroSpawnerScript:TrySetOwner(user)
	print("Handling player enter")
	self.owner = user
	
	self.travelNodeScripts = self:GetEntity():FindAllScripts("travelNodeScript")
	self.spawnIndex = 1
	
	-- can't spawn heroes without a reference
	if #self.travelNodeScripts == 0 then 
		return
	end
	
	self.db = user.documentStoresScript:GetDb("heroes")
	
	self:SpawnHeroesHere()

	self:SpawnUnassignedHeroes()
	
	self:Schedule(function() 
		while true do 
			Wait(60)
			
			self:CleanupHeroes()
			
			if math.random() < 0.5 and #self.heroes < 2 then 
				self:BringInHero()
			end
		end
		
	end)
end

function LocationHeroSpawnerScript:BringInHero()
	if #self.properties.entryPoints == 0 then return end 
	
	local heroes = self.db:Find({ 
		currentLocationId = {
			_ne = self.id
		}
	})
	
	if #heroes == 0 then return end 
	
	local hero = heroes[math.random(1, #heroes)]
	
	local position = self.properties.entryPoints[math.random(1, #self.properties.entryPoints)]
	
	local template = GetWorld():FindTemplate(hero.templateName)
	local heroEntity = self.owner.userHeroesScript:SpawnHero(hero, position:GetPosition(), position:GetRotation())
			
	heroEntity.idleNpcScript.properties.startNode = position
	heroEntity.idleNpcScript:Go()
	
	table.insert(self.heroes, heroEntity)
	
	self.db:UpdateOne({ _id = hero._id }, {
		_set = {
			currentLocationId = self.id
		}
	})
end

function LocationHeroSpawnerScript:SpawnUnassignedHeroes()
	local heroes = self.db:Find({ 
		currentLocationId = {
			_exists = false
		}
	})
	
	self:SpawnHeroes(heroes)
end

function LocationHeroSpawnerScript:SpawnHeroesHere()
	local heroes = self.db:Find({ 
		currentLocationId = self.id
	})
	
	self:SpawnHeroes(heroes)
end

function LocationHeroSpawnerScript:SpawnHeroes(heroes)
	for i=self.spawnIndex,#self.travelNodeScripts do 
		local hero = heroes[i]
		if hero then 
		
			if hero.currentLocationId ~= self.id then 
				self.owner:SendToScripts("UseDb", "heroes", function(db)
					db:UpdateOne({ _id = hero._id }, {
						_set = {
							currentLocationId = self.id
						}
					})
				end)
			end
		
			local position = self.travelNodeScripts[i]:GetEntity()
			
			local heroEntity = self.owner.userHeroesScript:SpawnHero(hero, position:GetPosition(), position:GetRotation())
			
			heroEntity.idleNpcScript.properties.startNode = position
			heroEntity.idleNpcScript:Go()
			
			table.insert(self.heroes, heroEntity)
			self.spawnIndex = self.spawnIndex + 1
		end
	end
end

function LocationHeroSpawnerScript:OnDestroy()
	for _, hero in ipairs(self.heroes) do 
		if Entity.IsValid(hero) then 
			hero:Destroy()
		end
		
	end
end


return LocationHeroSpawnerScript
