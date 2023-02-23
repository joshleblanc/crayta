local UserHeroMergeScript = {}

-- Script properties are defined here
UserHeroMergeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "goodResourceTemplate", type = "template" },
	{ name = "evilResourceTemplate", type = "template" }
}

--This function is called on the server when this entity is created
function UserHeroMergeScript:Init()
	self.widget = self:GetEntity().userHeroMergeWidget
	self.widget:Hide()
	
	self.selectedHeroes = {
		{}, {}
	}
	self.goodResources = 0
	self.evilResources = 0
	self.successChance = 0
end

function UserHeroMergeScript:LocalInit()
	self.widget = self:GetEntity().userHeroMergeWidget
end

function UserHeroMergeScript:IncResource(resource, amt) 
	if not IsServer() then 
		self:SendToServer("IncResource", resource, amt)
		return
	end
	
	local key = resource .. "Resources"
	local template = self.properties[resource .. "ResourceTemplate"]

	local count = self:GetEntity().inventoryScript:GetTemplateCount(template)
	
	if self.successChance >= 1 and amt > 0 then 
		return
	end
	
	if self.successChance <= 0 and amt < 0 then 
		return
	end

	self[key] = self[key] + amt
	
	if self[key] < 0 then 
		self[key] = 0
	end
	
	if self[key] > count then 
		self[key] = count
	end
	
	local total = self.goodResources + self.evilResources
	local rarity = self:GetRarity()
	self.successChance = math.min(1, (rarity * 0.1) + (total / 500) * rarity)
	
	self:UpdateMergeWidget()
end

function UserHeroMergeScript:RemoveHeroForMerge(ind)
	if not IsServer() then 
		self:SendToServer("RemoveHeroForMerge", ind)
		return
	end
	
	self.selectedHeroes[ind] = {}
	self:UpdateMergeWidget()
end

function UserHeroMergeScript:GetRarity()
	if not self.selectedHeroes[1]._id and not self.selectedHeroes[2]._id then 
		return 0
	end
	
	local tmp
	if self.selectedHeroes[1]._id and not self.selectedHeroes[2]._id then 
		tmp = self.selectedHeroes[1]
	end
	
	if not self.selectedHeroes[1]._id and self.selectedHeroes[2]._id then 
		tmp = self.selectedHeroes[2]
	end
	
	if self.selectedHeroes[1]._id and self.selectedHeroes[2]._id then 
		tmp = self.selectedHeroes[1]
	end
	
	local template = GetWorld():FindTemplate(tmp.templateName)
	return template:FindScriptProperty("weight")
end

function UserHeroMergeScript:SelectHeroForMerge(ind)
	if not IsServer() then 
		self:SendToServer("SelectHeroForMerge", ind)
		return
	end
	
	self:HideMergeWidget()
	
	local rarity = self:GetRarity()
	
	self:GetEntity().userHeroSelectScript:SelectHero(function(hero)
		self:ShowMergeWidget()
		
		if hero then 
			self.selectedHeroes[ind] = hero
			
			if self:CanMerge() then 
				self.successChance = rarity * 0.1
				self.goodResources = 0
				self.evilResources = 0
			end
			
			self:UpdateMergeWidget()
		end
	end, function(hero)
		if self:GetEntity().userHeroesScript:GetLevel(hero._id) < 10 then 
			return false 
		end
		
		for i=1,2 do 
			local selectedHero = self.selectedHeroes[i]
			if selectedHero then
				if selectedHero._id == hero._id then 
					print("excluding", hero.templateName)
	 				return false
	 			end
	 			
	 			if rarity > 0 then 
	 				local template = GetWorld():FindTemplate(hero.templateName)
	 				if rarity ~= template:FindScriptProperty("weight") then 
	 					return false
	 				end
	 			end
			end
		end

 		return true
	end)
end

function UserHeroMergeScript:CanMerge()
	for _, hero in ipairs(self.selectedHeroes) do
		if not hero._id then 
			return false
		end
	end
	return true
end

function UserHeroMergeScript:UpdateMergeWidget(selectedHeroes, goodResources, evilResources, successChance)
	if IsServer() then 
		self:SendToLocal("UpdateMergeWidget", self.selectedHeroes, self.goodResources, self.evilResources, self.successChance)
		return
	end
	
	self.widget.js.data.heroes = self:GetEntity().userHeroesScript:GetWidgetData(selectedHeroes)
	self.widget.js.data.goodResource = goodResources
	self.widget.js.data.evilResource = evilResources
	self.widget.js.data.successChance = successChance
end

function UserHeroMergeScript:DoMerge()
	if not IsServer() then 
		self:SendToServer("DoMerge")
		return
	end
	
	if not self:CanMerge() then 
		return
	end
	
	local roll = math.random()
	local weight = self:GetRarity()
	
	print("Doing merge", weight)
	
	if roll <= self.successChance then 
		weight = self:GetEntity().userHeroesScript:GetNextWeight(weight)
		print("successful merge, new weight", weight)
	end
	
	local newHero = self:GetEntity().userHeroesScript:GetNewHeroForWeight(weight)
	
	self:GetEntity():SendXPEvent("merge-hero")
		
	self:GetEntity().userHeroesScript:RemoveHero(self.selectedHeroes[1]._id)
	self:GetEntity().userHeroesScript:RemoveHero(self.selectedHeroes[2]._id)
	
	self:GetEntity().availableMissionsScript:RemoveMia(self.selectedHeroes[1]._id)
	self:GetEntity().availableMissionsScript:RemoveMia(self.selectedHeroes[2]._id)
	
	self:GetEntity().availableMissionsScript:EnsureMinimumMissions()
	
	local newHeroEntity = GetWorld():Spawn(newHero, Vector.Zero, Rotation.Zero)
	local newHeroDoc = self:GetEntity().userHeroesScript:AddHero(newHeroEntity.heroScript)
	
	self:GetEntity().documentStoresScript:UseDb("heroes", function(db)
		db:UpdateOne({
			_id = newHeroDoc._id
		}, {
			_inc = {
				goodAlignment = self.goodResources,
				evilAlignment = self.evilResources
			}
		})
	end)
	
	if newHeroEntity.heroScript:GetRarity() == "Legendary" then 
		self:GetEntity():AddToLeaderboardValue("number-legendaries", 1)
	end
	
	self:GetEntity().inventoryScript:RemoveTemplate(self.properties.goodResourceTemplate, self.goodResources)
	self:GetEntity().inventoryScript:RemoveTemplate(self.properties.evilResourceTemplate, self.evilResources)
	
	newHeroEntity:Destroy()
	
	self.selectedHeroes = { {}, {} }
	self.goodResources = 0
	self.evilResources = 0
	self.successChance = 0
	
	self:UpdateMergeWidget()
end

function UserHeroMergeScript:ShowMergeWidget()
 	print("Showing merge widget")
	self.widget:Show()
end

function UserHeroMergeScript:HideMergeWidget()
	print("Hiding merge widget")
	self.widget:Hide()
end

function UserHeroMergeScript:ExitHeroMerge()
	if not IsServer() then 
		self:SendToServer("ExitHeroMerge")
		return
	end
	
	self:HideMergeWidget()
	
	self:GetEntity().userLocationScript:GoBack()
end

return UserHeroMergeScript
