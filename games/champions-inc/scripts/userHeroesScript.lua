local UserHeroesScript = {}

-- Script properties are defined here
UserHeroesScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

local WEIGHTS = {
	5, 4, 3, 2, 1
}

--This function is called on the server when this entity is created
function UserHeroesScript:Init()
	self.db = self:GetEntity().documentStoresScript

	self:MiaSchedule()
	self:HealthRecoverySchedule()
	
	
	--[[
	self.db:UseDb("heroes", function(db)
		db:UpdateMany({}, {
			_unset = {
				mission = true
			}
		})
	end)
	--]]

end

function UserHeroesScript:SpawnHero(heroDoc, pos, rot)
	local template = GetWorld():FindTemplate(heroDoc.templateName)
	local heroEntity = GetWorld():Spawn(template, pos, rot)
	
	heroEntity:SendToScripts("SetId", heroDoc._id)
	heroEntity:SendToScripts("SetOwner", self:GetEntity())
	
	return heroEntity
end

function UserHeroesScript:OnRecordDeleted(t, doc)
	if t == "availableMissions" then 
		local query = {}
		query["mission._id"] = doc._id
		
		local heroes = self.db.heroes:Find(query)
		for _, hero in ipairs(heroes) do 
			self:UpdateHero(hero._id, {
				_unset = {
					mission = true
				}
			})
		end
	end
end

function UserHeroesScript:LocalInit()
	self.db = self:GetEntity().documentStoresScript
end

function UserHeroesScript:GetNextWeight(weight)
	print("Getting next weight", weight)
	for i, w in ipairs(WEIGHTS) do 
		print("Comparing weights", w, weight)
		if w == weight then 
			print("Weights equal, returning weight", i, i+1, WEIGHTS[i+1])
			return WEIGHTS[i + 1]
		end
	end
	return nil
end

function UserHeroesScript:GetHeroes()
	local heroes = self.db.heroes:Find()
	
	table.sort(heroes, function(a,b) 
		local templateA = GetWorld():FindTemplate(a.templateName)
		local templateB = GetWorld():FindTemplate(b.templateName)
		
		if templateA:FindScriptProperty("weight") < templateB:FindScriptProperty("weight") then 
			print("Sorting heroe, weightier")
			return true
		end
		
		if templateB:FindScriptProperty("weight") < templateA:FindScriptProperty("weight") then 
			return false
		end
		
		return a.xp > b.xp
	end)
	
	return heroes
end

function UserHeroesScript:GetNewHeroForWeight(weight)
	local lootTable = self:GetEntity().lootTableManagerScript:FindLootTable("All Heroes")
	local hero = lootTable:RandomFromWeight(weight)
	
	return hero
end

function UserHeroesScript:GetHeroesOfRarity(weight)
	local heroes = self:GetHeroes()
	local data = {}
	
	for _, hero in ipairs(heroes) do 
		local t = GetWorld():FindTemplate(hero.templateName)
		if t:FindScriptProperty("weight") == weight and self:GetEntity().userStatScript:LevelFromXp(hero.xp) >= 10 then 
			table.insert(data, hero)
		end
	end
	
	return self:GetWidgetData(data)
end

function UserHeroesScript:HealthRecoverySchedule()
	self:Schedule(function()
		while true do
			local currHour = math.floor(GetWorld():GetUTCTime() / 3600)

			local heroes = self.db.heroes:Find({ 
				mia = {
					_not = {
						_eq = true
					}
				},
				_or = {
					{ lastHealHour = { _lt = currHour } },
					{ lastHealHour = { _exists = false } }	
				}
			})
			
			for _, hero in ipairs(heroes) do 
				print("healing hero", hero._id, hero.lastHealHour, currHour, hero.mia)
				local maxHealth = self:GetStatLevel(hero._id, "health")
				local healthMissing = maxHealth - hero.availableHealth
				local hoursPassed = currHour - (hero.lastHealHour or currHour)
				local healAmount = math.min(healthMissing, hoursPassed)
				
				self:UpdateHero(hero._id, {
					_inc = {
						availableHealth = healAmount
					},
					_set = {
						lastHealHour = currHour
					}
				})
			end
		 
			Wait(1)
		end
	end)
end

function UserHeroesScript:MiaSchedule()
	self:Schedule(function()
		while true do 
			local mias = self.db.heroes:Find({ mia = true })
				
			for _, mia in ipairs(mias) do 
				local recoversAt = self:MiaEnd(mia._id)
				print("Checking recovery", recoversAt, GetWorld():GetUTCTime())
				if GetWorld():GetUTCTime() >= recoversAt then 
					self:UpdateHero(mia._id, { 
						_set = {
							mia = false
						}
					})
					
					self:GetEntity().availableMissionsScript:RemoveMia(mia._id)
					
					local template = GetWorld():FindTemplate(mia.templateName)
					self:GetEntity():SendToScripts("AddNotification", FormatString("{1} has recovered", template:FindScriptProperty("name")))
				end
			end	
			Wait(1)
		end
	end)
end

function UserHeroesScript:GetXp(id)
	local hero = self.db.heroes:FindOne({ _id = id })
	if hero then 
		return math.floor(hero.xp)
	else 
		return 0
	end
end

function UserHeroesScript:RemoveHealth(id)
	local doc = self:UpdateHero(id, {
		_inc = {
			availableHealth = -1
		}
	})
	
	local template = GetWorld():FindTemplate(doc.templateName)
	if doc.availableHealth <= 0 then 
		self:GetEntity():SendToScripts("AddNotification", FormatString("{1} is MIA!", template:FindScriptProperty("name")))
	else 
		self:GetEntity():SendToScripts("AddNotification", FormatString("{1} has lost health!", template:FindScriptProperty("name")))
	end
end

function UserHeroesScript:GetXpPercent(id)
	return FormatString("{1}%", math.floor((self:GetXp(id) / self:GetXpRequired(id)) * 100))
end

function UserHeroesScript:GetStrengthLevel(id)
	return self:GetStatLevel(id, "strength")
end

function UserHeroesScript:GetIntelligenceLevel(id)
	return self:GetStatLevel(id, "intelligence")
end

function UserHeroesScript:GetHealthLevel(id)
	return self:GetStatLevel(id, "health")
end

function UserHeroesScript:GetHealthPercent(heroId)
	local percent = (self:GetAvailableHealth(heroId) / self:GetHealthLevel(heroId)) * 100
	return FormatString("{1}%", math.floor(percent))
end

function UserHeroesScript:GetAvailableHealth(heroId)
	local hero = self:FindOne(heroId)
	if not hero then 
		return 0
	end
	
	if not hero.availableHealth then 
		self:UpdateHero(heroId, {
			_set = {
				availableHealth = self:GetHealthLevel()
			}
		})
	end
	
	return self:FindOne(heroId).availableHealth
end

function UserHeroesScript:GetStat(heroId, statId)
	local hero = self.db.heroes:FindOne({ _id = heroId })
	if hero then 
		return hero.stats[statId]
	else
		return 0
	end
end

function UserHeroesScript:StatSum(heroId)
	local doc = self.db.heroes:FindOne({ _id = heroId })
	local sum = 0
	
	if not doc then 
		return sum
	end
	
	for _, v in pairs(doc.stats) do 
		sum = sum + v
	end
	
	return sum 
end

function UserHeroesScript:UnsetMia(heroId)
	self:UpdateHero(heroId, {
		_set = {
			mia = false,
			availableHealth = 1,
		},
		_unset = {
			miaAt = true
		}
	})
end

function UserHeroesScript:SetMia(heroId)
	self:UpdateHero(heroId, {
		_set = {
			mia = true,
			miaAt = GetWorld():GetUTCTime()
		}
	})
	
	self:GetEntity().availableMissionsScript:AddMia(heroId)
end

function UserHeroesScript:IsDead(heroId)
	local hero = self:FindOne(heroId)
	if hero then 
		return hero.availableHealth <= 0
	else 
		return true
	end
	
end

function UserHeroesScript:MiaRemaining(heroId)
	if not self:IsMia(heroId) then return 0 end 
	return Text.FormatTime("{hh}:{mm}:{ss}", (self:MiaEnd(heroId) - GetWorld():GetUTCTime()))
end

function UserHeroesScript:HasRecovered(heroId)
	return GetWorld():GetUTCTime() >= self:MiaEnd(heroId)
end


function UserHeroesScript:MiaEnd(heroId)
	local hero = self:FindOne(heroId) 
	if hero then 
		return (hero.miaAt or 0) + (60 * 60 * 1) -- 1 hour
	else 
		return 0
	end
	
end

function UserHeroesScript:IsMia(heroId)
	local hero = self:FindOne(heroId)
	return hero and hero.mia
end

function UserHeroesScript:IsAvailable(heroId)
	local hero = self:FindOne(heroId)
	--return hero and not hero.assignedRoom
	return hero and not hero.mission
end

function UserHeroesScript:FindHero(id)
	return self:FindOne(id)
end

function UserHeroesScript:FindOne(id)
	return self.db.heroes:FindOne({ _id = id })
end

function UserHeroesScript:GetStats(heroId)
	local hero = self.db.heroes:FindOne({ _id = heroId })
	if hero then 
		return hero.stats
	else 
		return {}
	end
end

function UserHeroesScript:GetStatLevel(heroId, statId)
	local stat = self:GetStat(heroId, statId)
	
	local ratio = stat / self:StatSum(heroId)
	
	local doc = self.db.heroes:FindOne({ _id = heroId })

	if doc then 
		local level = self:GetLevel(heroId)
	
		return math.floor(stat + (level * ratio))
	else 
		return stat
	end

end

function UserHeroesScript:GetXpRequired(id)
	local nextLevel = self:GetLevel(id) + 1
	return self:GetEntity().userStatScript:XpForLevel(nextLevel)
end

function UserHeroesScript:GetLevel(id)
	local doc = self.db.heroes:FindOne({ _id = id })
	return self:GetEntity().userStatScript:LevelFromXp(doc.xp)
end

function UserHeroesScript:AddHero(heroScript)
	local stats = heroScript:GetBaseStats()
	
	local statsDoc = {}
	for k, v in pairs(stats) do 
		statsDoc[k] = v
	end

	local hero = self.db.heroes:InsertOne({
		templateName = heroScript:GetEntity():GetTemplate():GetName(),
		stats = statsDoc,
		availableHealth = statsDoc.health,
		mia = false,
		xp = 0
	})
	
	self:GetEntity():SendToScripts("AddNotification", FormatString("You received {1} ({2})", heroScript.properties.name, heroScript:GetRarity()))
	
	self:GetEntity().availableHeroesScript:PurchaseHero(heroScript)
	
	return hero
end

function UserHeroesScript:HasAnyHeroes()
	return #self:GetHeroes() > 0
end

function UserHeroesScript:RemoveHero(id)
	local hero = self:FindOne(id)
	local room
	
	if hero.assignedRoom then 
		self:GetEntity().userRoomScript:UpdateRoom(hero.assignedRoom, {
			_unset = {
				assignedHero = true,
				activeMission = true
			}
		})
	end
	
	self.db.heroes:DeleteOne({ _id = id })
end

function UserHeroesScript:AssignToRoom(id, roomId)

	-- if there's already a hero in this room, we need to remove them
	local room = self.db.rooms:FindOne({ _id = roomId })
	if room and room.assignedHero then 
		self:UpdateHero(room.assignedHero, {
			_unset = {
				assignedRoom = true
			}
		})
	end
	
	
	self:GetEntity().userRoomScript:UpdateRoom(roomId, {
		_set = {
			assignedHero = id
		}
	})
	
	self:UpdateHero(id, { 
		_set = {
			assignedRoom = roomId
		}
	})
end

function UserHeroesScript:UpdateHero(id, query)
	local hero = self.db.heroes:UpdateOne({ _id = id }, query)
	
	
	return hero
end

function UserHeroesScript:GetWidgetDatum(hero)
	if not hero.templateName then return nil end
	
	local template = GetWorld():FindTemplate(hero.templateName)
	if not template then return nil end
	
	return {
				id = hero._id,
				name = template:FindScriptProperty("name"),
				description = template:FindScriptProperty("description"),
				weight = template:FindScriptProperty("weight"),
				level = self:GetEntity().userStatScript:LevelFromXp(hero.xp),
				strength = self:GetStatLevel(hero._id, "strength"),
				intelligence = self:GetStatLevel(hero._id, "intelligence"),
				assignedRoom = hero.assignedRoom,
				mia = hero.mia,
				iconUrl = template:FindScriptProperty("iconUrl")
			}
end

function UserHeroesScript:GetWidgetData(heroes)
	local data = {}
	
	for _, hero in ipairs(heroes) do 
		if hero then 
			local datum = self:GetWidgetDatum(hero)
			if datum then 
				table.insert(data, datum)
			end
			
		end
	end
	
	return data
end

function UserHeroesScript:GetHeroesWidgetData()
	return self:GetWidgetData(self:GetHeroes())
end

function UserHeroesScript:GetLevel(heroId) 
	local xp = self:GetXp(heroId)
	
	return self:GetEntity().userStatScript:LevelFromXp(xp)
end

function UserHeroesScript:CalcDuration(duration, int)
	return duration - math.max(5, (duration * (int / 50)))
end

function UserHeroesScript:CalcDifficulty(difficulty, str)
	return math.max(0, difficulty - (str / 250))
end

function UserHeroesScript:AddXp(heroId, xp)
	local hero = self.db.heroes:FindOne({ _id = heroId })
	local template = GetWorld():FindTemplate(hero.templateName)
	local levelBefore = self:GetEntity().userStatScript:LevelFromXp(hero.xp)
	
	hero = self:UpdateHero(heroId, { _inc = { xp = xp } })
	
	local levelAfter = self:GetEntity().userStatScript:LevelFromXp(hero.xp)
	
	if levelAfter > levelBefore then 
		self:GetEntity():SendToScripts("AddNotification", FormatString("{1} leveled up to level {2}", template:FindScriptProperty("name"), levelAfter))
		self:GetEntity():GetLeaderboardValue("highest-level-hero", function(score, rank)
			if levelAfter > score then 
				self:GetEntity():SetLeaderboardValue("highest-level-hero", levelAfter)
			end
		end)
		
		self:UpdateHero(heroId, {
			_set = {
				availableHealth = self:GetHealthLevel(heroId)
			}
		})
	else
		self:GetEntity():SendToScripts("AddNotification", FormatString("{1} gained {2} xp", template:FindScriptProperty("name"), xp))
	end
end

return UserHeroesScript
