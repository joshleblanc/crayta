local AvailableMissionsScript = {}

-- Script properties are defined here
AvailableMissionsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "numOptions", type = "number", default = 5 },
	{ name = "rescueMission", type = "template" },
	{ name = "forceRefresh", type = "boolean" },
	{ name = "successfulMissionSound", type = "soundasset" },
	{ name = "failMissionSound", type = "soundasset" }
}

--This function is called on the server when this entity is created
function AvailableMissionsScript:Init()
	self.db = self:GetEntity().documentStoresScript:GetDb("availableMissions")
	
	self:Schedule(function()
		Wait()
		self:EnsureMinimumMissions()
	end)
	
	
	self:ActiveMissionSchedule()
end

function AvailableMissionsScript:LocalInit()
	self.db = self:GetEntity().documentStoresScript:GetDb("availableMissions")
end

function AvailableMissionsScript:ActiveMissionSchedule()
	self:Schedule(function()
		while true do 
			Wait(1)
			
			local missions = self.db:Find({ inProgress = true })
			for _, mission in ipairs(missions) do 
				self:UpdateActiveMission(mission)
			end
			
		end
	end)
end

function AvailableMissionsScript:UpdateActiveMission(mission)

	local template = GetWorld():FindTemplate(mission.templateName)

	--local hero = self.owner.documentStoresScript:GetDb("heroes"):FindOne({ _id = self.heroEntity.heroScript.properties.id })
	
	--self.timeLeft = mission.data.endTime - GetWorld():GetUTCTime()
	
	if mission.endTime and GetWorld():GetUTCTime() < mission.endTime then 
		--self.widget.properties.time = Text.FormatTime("{hh}:{mm}:{ss}", self.timeLeft)
		return 
	end 
	
	--[[
	if self.missionComplete  then 
		self.widget.properties.time = Text.Format("")
		self.widget.properties.text = Text.Format("Mission Complete")
		return
	end
	]]--
	
	if mission.result then return end -- mission's already complete
	
	--self:GetEntity():SendToScripts("AddNotification", FormatString("{1} is complete", template:FindScriptProperty("name")))

	
	local roll = math.random()
	
	local chance = template:FindScriptProperty("difficulty")
	
	local strength = mission.data.strength
	
	chance = chance - (strength / 1000)
	
	local result
	if roll > chance then 
		result = "success"
		self:GetEntity():GetPlayer():PlaySound(self.properties.successfulMissionSound)
		self:GetEntity():SendToScripts("AddNotification", FormatString("{1} mission has been successfully completed.", template:FindScriptProperty("name")))
	else
		result = "fail"
		self:GetEntity():GetPlayer():PlaySound(self.properties.failMissionSound)
		self:GetEntity():SendToScripts("AddNotification", FormatString("{1} mission has failed.", template:FindScriptProperty("name")))
	end 
	
	local updatedMission = self.db:UpdateOne({ _id = mission._id }, {
		_set = {
			result = result
		}
	})
	
	
	GetWorld():BroadcastToScripts("OnMissionCompleted", self:GetEntity(), updatedMission, result)	
end

function AvailableMissionsScript:GetMissionWidgetData(mission, strengthLevel, intelligenceLevel)
	local template = GetWorld():FindTemplate(mission.templateName)
	
	local duration = template:FindScriptProperty("duration") * 60
	duration = self:GetEntity().userHeroesScript:CalcDuration(duration, intelligenceLevel)
	
	local heroes = self:GetEntity().documentStoresScript.heroes
	local rooms = self:GetEntity().documentStoresScript:GetDb("rooms")
	
	local missionName = template:FindScriptProperty("name")
	if mission.heroId then 
		local hero = heroes:FindOne({ _id = mission.heroId })
		
		if hero then 
			local heroTemplate = GetWorld():FindTemplate(hero.templateName)
			local heroName = heroTemplate:FindScriptProperty("name")
			
			printf("Found hero {1} from id {2}", heroName, mission.heroId)
			missionName = FormatString("Rescue {1}", heroName)
		end
	end
	
	local difficulty = template:FindScriptProperty("difficulty")
	
	local xpReward = math.max(100, 650 * difficulty * (duration / 60))
	
	local resourceReward = math.floor(xpReward / 123)
	
	difficulty = self:GetEntity().userHeroesScript:CalcDifficulty(difficulty, strengthLevel)
	
	--[[
	local query = {}
	query["activeMission.mission.id"] = mission._id
	local activeMission = rooms:FindOne(query)
	local activeHeroName
	if activeMission then 
		local activeHero = heroes:FindOne({ _id = activeMission.assignedHero })
		if activeHero then 
			local template = GetWorld():FindTemplate(activeHero.templateName)
			activeHeroName = template:FindScriptProperty("name")
		end
	end
	]]--
	
	local insertionData = {
		id = mission._id,
		name = tostring(missionName),
		description = tostring(template:FindScriptProperty("description")),
		duration = tostring(Text.FormatTime("{hh}:{mm}:{ss}", duration)),
		difficulty = difficulty,
		strength = strengthLevel,
		intelligence = intelligenceLevel,
		xpReward = math.ceil(xpReward),
		moneyReward = math.ceil(xpReward / 2),
		percentChance = FormatString("{1}%", 100 - math.floor(difficulty * 100)),
		alignment = template:FindScriptProperty("alignment"),
		rescuingHeroId = mission.heroId,
		endTime = mission.endTime,
		result = mission.result,
		timeRemaining = mission.endTime and tostring(Text.FormatTime("{hh}:{mm}:{ss}", mission.endTime - GetWorld():GetUTCTime())),
		inProgress = mission.inProgress,
		resourceReward = resourceReward
	}
	return insertionData
end

function AvailableMissionsScript:GetMissionsWidgetData()
	local missions = self:GetCurrentSelection()
	local data = {}
	
	for _, mission in ipairs(missions) do 
		local template = GetWorld():FindTemplate(mission.templateName)
		
		local strengthLevel = 0
		local intelligenceLevel = 0
		
		if mission.data then 
			strengthlevel = mission.data.strength
			intelligenceLevel = mission.data.intelligence
		end
		
		local insertionData = self:GetMissionWidgetData(mission, strengthLevel, intelligenceLevel)
		if mission.heroId then 
			print("Adding rescue mission", insertionData.name, insertionData.duration, insertionData.difficulty)
			table.insert(data, 1, insertionData) -- put rescue missions at the top
		else 
			table.insert(data, insertionData)
		end
	end
	
	return data
end

function AvailableMissionsScript:GetCurrentSelection()

	local db = self:GetEntity().documentStoresScript:GetDb("default")
	local doc = db:FindOne() 
	
	if not doc then return {} end 
	
	local availableMissionsDB = self:GetEntity().documentStoresScript.availableMissions
	
	local day = GetWorld():GetUTCTime()
	day = math.floor(day / 86400)

	local options = {}
	
	local heroesDb = self:GetEntity().documentStoresScript:GetDb("heroes")
	local rescueMissions = availableMissionsDB:Find({ heroId = { _exists = true }})
	for _, miss in ipairs(rescueMissions) do
		local hero = heroesDb:FindOne({ _id = miss.heroId })
		if not hero.mia then 
			self.db:DeleteOne({ _id = miss._id })
		end
	end
	
	if (not doc.missionsInitialized or self.properties.forceRefresh) and IsServer() then
		print("Generating new mission selection")
		self.properties.forceRefresh = false 
		 
		for i=1,self.properties.numOptions do 
			local option = self:GetEntity().lootTableManagerScript:FindLootTable("Missions"):FindItemByChance()
			table.insert(options, {
				templateName = option:GetName(),
				inProgress = false
			})
		end
		
		db:UpdateOne({}, {
			_set = {
				lastMissionSelectionDay = day,
				missionsInitialized = true
			}
		})
		
		local mias = self:GetMia()
	
		if #mias > 0 then 
			for _, mia in ipairs(self:GetMia()) do 
				local data = {
					templateName = self.properties.rescueMission:GetName(),
					inProgress = false,
					heroId = mia._id
				}
				table.insert(options, data)
			end	
		end
	
		availableMissionsDB:DeleteMany()
		options = availableMissionsDB:InsertMany(options)
	else
		options = availableMissionsDB:Find()
	end
	
	table.sort(options, function(a,b) 
		if a.result and not b.result then 
			return true
		end
		
		if b.result and not a.result then 
			return false
		end
		
		if a.inProgress and not b.inProgress then 
			return true
		end
		
		if b.inProgress and not a.inProgress then 
			return false
		end
		
		return a.templateName < b.templateName
	end)
	
	return options
end

function AvailableMissionsScript:StandardMissions()
	local availableMissionsDB = self:GetEntity().documentStoresScript:GetDb("availableMissions")
	return availableMissionsDB:Find({ 
		heroId = {
			_ne = true
		}
	})
end

function AvailableMissionsScript:EnsureMinimumMissions()
	if not IsServer() then return end 
	
	local availableMissionsDB = self:GetEntity().documentStoresScript:GetDb("availableMissions")
	local heroesDb = self:GetEntity().documentStoresScript:GetDb("heroes")
	
	local missions = self:StandardMissions()
	
	print("Ensuring minimum missions", #missions, #self.db:Find())
	
	while #missions > self.properties.numOptions do 
		local missionDeleted = self.db:DeleteOne({ _heroId = { _ne = true }})
	
		missions = self:StandardMissions()
		
		print("Removing excess missions", #missions, self.properties.numOptions)
		Wait()
	end
	
	while #missions < self.properties.numOptions do 
		local option = self:GetEntity().lootTableManagerScript:FindLootTable("Missions"):FindItemByChance()
		availableMissionsDB:InsertOne({
			templateName = option:GetName(),
			inProgress = false
		})
		
		missions = self:StandardMissions()
	end
end

function AvailableMissionsScript:ReplaceMission(missionId)
	local availableMissionsDB = self:GetEntity().documentStoresScript.availableMissions
	
	self.db:DeleteOne({ _id = missionId })
	
	self:EnsureMinimumMissions()
end

function AvailableMissionsScript:AddMia(heroId)
	local availableMissionsDB = self:GetEntity().documentStoresScript.availableMissions
	
	availableMissionsDB:InsertOne({
		templateName = self.properties.rescueMission:GetName(),
		inProgress = false,
		heroId = heroId
	})
end

function AvailableMissionsScript:RemoveMia(heroId)
	local availableMissionsDB = self:GetEntity().documentStoresScript.availableMissions
	
	self.db:DeleteOne({ heroId = heroId })
end

function AvailableMissionsScript:GetMia()
	return self:GetEntity().documentStoresScript.heroes:Find({ mia = true })
end

return AvailableMissionsScript
