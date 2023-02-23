local UserControlPanelScript = {}

-- Script properties are defined here
UserControlPanelScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "goodResource", type = "template" },
	{ name = "evilResource", type = "template" },
	{ name = "startMissionSound", type = "soundasset" },
	{ name = "addHeroToMissionSound", type = "soundasset" },
	{ name = "removeHeroFromMissionSound", type = "soundasset" },

}

--This function is called on the server when this entity is created
function UserControlPanelScript:Init()
	self.db = self:GetEntity().documentStoresScript
	
	self.widget = self:GetEntity().userControlPanelWidget
	self.widget:Hide() 
	self.heroesScript = self:GetEntity().userHeroesScript
end

function UserControlPanelScript:LocalInit()
	self:Init()
	
	self.selectedHeroes = {}
	self.selectedMission = nil
	
	self.heroesScript = self:GetEntity().userHeroesScript
	
	self:MissionSchedule()
end

--[[
			local rescuedHeroId = self.room.activeMission.mission.rescuingHeroId
			if self.room.missionCompleteResult == "success" then 
			
				self:GetEntity().userMoneyScript:AddMoney(self.room.activeMission.mission.moneyReward)
				
				self.heroesScript:AddXp(self:GetHeroId(), self.room.activeMission.mission.xpReward)
				
				
				if rescuedHeroId then 
					local rescuedHero = self.heroesScript:FindOne(rescuedHeroId)
					local rescuedHeroTemplate = GetWorld():FindTemplate(rescuedHero.templateName)
					self:GetEntity():SendToScripts("AddNotification", FormatString("{1} has been rescued", rescuedHeroTemplate:FindScriptProperty("name")))

					-- don't think this broadcast is used
					GetWorld():BroadcastToScripts("HeroRescued", rescuedHeroId)
					
					self:GetEntity().userHeroesScript:UnsetMia(rescuedHeroId)
					self:GetEntity().availableMissionsScript:RemoveMia(rescuedHeroId)
				end
				
				self:GetEntity():AddToLeaderboardValue("most-successful-missions", 1)
				
				local alignmentBoard = FormatString("{1}-points", self.room.activeMission.mission.alignment)
				self:GetEntity():AddToLeaderboardValue(alignmentBoard, 1)
			else	
				self:GetEntity().userHeroesScript:RemoveHealth(heroId, 1)
				if heroEntity and self.heroesScript:IsDead(self:GetHeroId()) then 
					self.heroesScript:SetMia(self:GetHeroId())
				end
			end
			
			if not rescuedHeroId then 
				self:GetEntity().availableMissionsScript:ReplaceMission(self.room.activeMission.mission.id)
			end
			
			self.widget.properties.inProgress = false
			self.widget.properties.inProgressComplete = false
			self.room:RemoveMission()
			
			self:GetEntity():SendXPEvent("mission-complete", { result = self.room.missionCompleteResult })
			
			self:UpdateAllWidgets()
]]--

function UserControlPanelScript:CompleteMissionControlPanel(missionId)
	if not IsServer() then 
		self:SendToServer("CompleteMissionControlPanel", self.selectedMission._id)
		self.selectedMission = nil
		self.widget.js.data.selectedMission = nil
		
		return
	end 
	
	local mission = self.db:GetDb("availableMissions"):FindOne({ _id = missionId })
	
	print("Mission result", mission, mission.result)
	local rescuedHeroId = mission.rescuingHeroId
	if mission.result == "success" then 
	
		if mission.data.resourceReward and mission.data.resourceReward > 0 then 
			if mission.data.alignment == "good" then 
				self:GetEntity().inventoryScript:AddToInventory(self.properties.goodResource, mission.data.resourceReward)
			else
				self:GetEntity().inventoryScript:AddToInventory(self.properties.evilResource, mission.data.resourceReward)
			end
		end
		
		self:GetEntity().userMoneyScript:AddMoney(mission.data.moneyReward)
		
		local xpReward = mission.data.xpReward 
		local xpSplit = xpReward / #mission.assignedHeroes
		
		for _, hero in ipairs(mission.assignedHeroes) do 
			self.heroesScript:AddXp(hero._id, xpSplit)
		end
		
		if rescuedHeroId then 
			local rescuedHero = self.heroesScript:FindOne(rescuedHeroId)
			local rescuedHeroTemplate = GetWorld():FindTemplate(rescuedHero.templateName)
			self:GetEntity():SendToScripts("AddNotification", FormatString("{1} has been rescued", rescuedHeroTemplate:FindScriptProperty("name")))

			-- don't think this broadcast is used
			GetWorld():BroadcastToScripts("HeroRescued", rescuedHeroId)
			
			self:GetEntity().userHeroesScript:UnsetMia(rescuedHeroId)
			self:GetEntity().availableMissionsScript:RemoveMia(rescuedHeroId)
		end
		
		self:GetEntity():AddToLeaderboardValue("most-successful-missions", 1)
		
		
		local alignmentBoard = FormatString("{1}-points", mission.data.alignment)
		self:GetEntity():AddToLeaderboardValue(alignmentBoard, 1)
	else	
		for _, hero in ipairs(mission.assignedHeroes) do 
			self:GetEntity().userHeroesScript:RemoveHealth(hero._id, 1)
			if self.heroesScript:IsDead(hero._id) then 
				self.heroesScript:SetMia(hero._id)
			end
		end
		
	end
	
	self.db:GetDb("availableMissions"):UpdateOne({ _id = mission._id }, {
		_set = {
			inProgress = false,
			assignedHeroes = {},
		},
		_unset = {
			result = true
		}
	})	
	
	for _, hero in ipairs(mission.assignedHeroes) do 
		self.heroesScript:UpdateHero(hero._id, {
			_unset = {
				mission = true
			}
		})
	end
	
	if not rescuedHeroId then 
		self:GetEntity().availableMissionsScript:ReplaceMission(mission._id)
	end
	
	self:SendToLocal("UpdateMissions")
	
	self:GetEntity():SendXPEvent("mission-complete", { result = mission.result })
end

function UserControlPanelScript:MissionSchedule()
	self:Schedule(function()
		while true do
			self:UpdateMissions()
			if self.selectedMission then 
				self:UpdateSelectedMission(self.selectedMission._id)
			end
			
			Wait(1)
		end
	end)
end

function UserControlPanelScript:Show()
	if IsServer() then 
		self:SendToLocal("Show")
		return
	end
	
	self.selectedMission = nil
	self.selectedHeroes = {}
	self.widget.js.data.selectedMission = nil
		
	self:UpdateMissions()

	self.widget:Show()
	self:InternalShow()
end

function UserControlPanelScript:InternalShow()
	self.widget:CallFunction("Show")
	self.widget.requiresCursor = true
end

function UserControlPanelScript:UpdateMissions()
	local missions = self:GetEntity().availableMissionsScript:GetMissionsWidgetData()
	self:ClearMissionsWidget()
	for _, mission in ipairs(missions) do 
		self:SendMissionToWidget(mission)
	end
	self:FinalizeMissionSend()
end

function UserControlPanelScript:SetSelectedHeroesFromMission(missionId)
	local mission = self.db:GetDb("availableMissions"):FindOne({ _id = missionId })
	
	self.selectedMission = mission
	self.selectedHeroes = mission.assignedHeroes or {}
	
	local data = {}
	for i=1,3 do 
		local datum = self.selectedHeroes[i]
		if datum then 
			data[i] = self:GetEntity().userHeroesScript:GetWidgetDatum(datum)
		else
			data[i] = {}
		end
	end
	
	self.widget.js.data.selectedHeroes =data
	
	self:UpdateSelectedMission(missionId)
end

function UserControlPanelScript:ClearMissionsWidget()
	self.widget:CallFunction("ClearMissions")
end

function UserControlPanelScript:SendMissionToWidget(mission)
	self.widget:CallFunction("AddMission", mission)
end

function UserControlPanelScript:FinalizeMissionSend()
	self.widget:CallFunction("FinalizeMissions")
end

function UserControlPanelScript:Hide()
	self.widget:Hide()
end

--[[
function UserRoomScript:StartMission(missionId)
	if not IsServer() then 
		self:SendToServer("StartMission", missionId)
		return
	end
	
	self:GetEntity().documentStoresScript:UseDb("availableMissions", function(availableMissionsDb)
		local missionDoc = availableMissionsDb:FindOne({ _id = missionId })
		local template = GetWorld():FindTemplate(missionDoc.templateName)
		
		local duration = template:FindScriptProperty("duration") * 60
		local intelligence = self:GetEntity().userHeroesScript:GetStatLevel(self:GetHeroEntity().heroScript.properties.id, "intelligence")
		local strength = self:GetEntity().userHeroesScript:GetStatLevel(self:GetHeroEntity().heroScript.properties.id, "strength")
		
		duration = self:GetEntity().userHeroesScript:CalcDuration(duration, intelligence)
		
		local endTime = GetWorld():GetUTCTime() + duration
		
		self.widget.properties.inProgress = true
		self.widget.properties.inProgressComplete = false
		self.widget.properties.inProgressResult = nil
		self.widget.properties.inProgressMission = template:FindScriptProperty("name")
		self.widget.properties.inProgressTimeLeft = Text.FormatTime("{hh}:{mm}:{ss}", endTime - GetWorld():GetUTCTime())
		
		local str = self:GetEntity().userHeroesScript:GetStatLevel(heroId, "strength")
		local int = self:GetEntity().userHeroesScript:GetStatLevel(heroId, "intelligence")
		local room = self:UpdateRoom(self.room.baseRoom.properties.id, {
			_set = {
				activeMission = {
					id = missionId,
					templateName = template:GetName(),
					startTime = GetWorld():GetUTCTime(),
					endTime = endTime,
					mission = self:GetEntity().availableMissionsScript:GetMissionWidgetData(missionDoc, str, int)
				}
			}
		})
		self.room:SetActiveMission(room.activeMission)
		self:UpdateActiveMission()
		
		GetWorld():BroadcastToScripts("OnMissionStarted", self.room:GetEntity())
	end)

	self.detailsOpen = false 
	self.missionsOpen = false
	self.detailsWidget:Hide()
	self.userRoomMissionsWidget:Hide()
	self:SetRoom(self.room)
end
]]--

function UserControlPanelScript:StartMissionControlPanel(id)
	print("Starting mission", id)
	if #self.selectedHeroes <= 0 then return end
	
	print("Starting mission - has assigned heroes")
	
	local mission = self.db:GetDb("availableMissions"):FindOne({ _id = id })
	self:GetEntity():GetPlayer():PlaySound(self.properties.startMissionSound)
	print("Starting mission - found mission", mission)
	
	if not mission then return end 
	
	print("Starting mission - mission exists", mission.inProgress)
	
	if mission.inProgress then return end
	
	local template = GetWorld():FindTemplate(mission.templateName)
	local duration = template:FindScriptProperty("duration") * 60

	local str = 0
	local int = 0
	
	local heroes = {}
	for i=1,3 do 
		local hero = self.selectedHeroes[i]
		if hero then 
			table.insert(heroes, self:GetEntity().userHeroesScript:FindHero(hero._id))
			
			str = str + self:GetEntity().userHeroesScript:GetStatLevel(hero._id, "strength")
			int = int + self:GetEntity().userHeroesScript:GetStatLevel(hero._id, "intelligence")
			
			-- update the hero after inserting it into the table to avoid rescursive nesting
			self:GetEntity().userHeroesScript:UpdateHero(hero._id, {
				_set = {
					mission = mission
				}
			})
		end
	end
	
	local extendedMissionData = self:GetEntity().availableMissionsScript:GetMissionWidgetData(mission, str, int)
		
	duration = self:GetEntity().userHeroesScript:CalcDuration(duration, int)
		
	local endTime = GetWorld():GetUTCTime() + duration
	
	self.db:GetDb("availableMissions"):UpdateOne({ _id = id }, {
		_set = {
			assignedHeroes = heroes,
			inProgress = true,
			endTime = GetWorld():GetUTCTime() + duration,
			data = extendedMissionData
		}
	})
	
	self:UpdateMissions()
end

function UserControlPanelScript:SelectHeroForMission(index, missionId, alreadySelected)
	self.widget:CallFunction("Hide")
	self.widget.requiresCursor = false

	if not IsServer() then 
		self:SendToServer("SelectHeroForMission", index, missionId, self.selectedHeroes)
		return
	end
	
	self:GetEntity().userHeroSelectScript:SelectHero(function(hero)
		print("Showing widget")
		self:SendToLocal("InternalShow")
		
		if hero then 
			self:SendToLocal("SendSelectedHeroToWidget", index, missionId, hero)
			self:GetEntity():GetPlayer():PlaySound(self.properties.addHeroToMissionSound)
		end
	end, function(hero)
		for i=1,3 do 
			local selectedHero = alreadySelected[i]
			if selectedHero then
				if selectedHero._id == hero._id then 
	 				return false
	 			end
			end
		end

 		return true
	end)
end

function UserControlPanelScript:RemoveHeroForMission(index, missionId) 
	self.selectedHeroes[index+1] = nil
	self:GetEntity():GetPlayer():PlaySound(self.properties.removeHeroFromMissionSound)
	local data = {}
	
	for i=1,3 do 
		local datum = self.selectedHeroes[i]
		if datum then
			data[i] = self:GetEntity().userHeroesScript:GetWidgetDatum(datum)
		else
			data[i] = {}
		end
	end
	
	self.widget.js.data.selectedHeroes = data
	
	self:UpdateSelectedMission(missionId)
end

function UserControlPanelScript:UpdateSelectedMission(missionId)
	local mission = self.db:GetDb("availableMissions"):FindOne({ _id = missionId })
	
	if mission == nil then 
		local missions = self:GetEntity().documentStoresScript:GetDb("availableMissions"):Find()
		self.selectedMission = nil
		return
	end
	
	local str = 0
	local int = 0
	
	for i=1,3 do 
		local hero = self.selectedHeroes[i]
		if hero then 
			str = str + self:GetEntity().userHeroesScript:GetStatLevel(hero._id, "strength")
			int = int + self:GetEntity().userHeroesScript:GetStatLevel(hero._id, "intelligence")
		end
	end
	self.widget.js.data.selectedMission = self:GetEntity().availableMissionsScript:GetMissionWidgetData(mission, str, int)
end

function UserControlPanelScript:SendSelectedHeroToWidget(index, missionId, hero)
	
	self.selectedHeroes[index+1] = hero
	
	local data = {}
	for i=1,3 do 
		local datum = self.selectedHeroes[i]
		
		if datum then 
			data[i] = self:GetEntity().userHeroesScript:GetWidgetDatum(datum)
		else
			data[i] = {}
		end
	end
	
	self.widget.js.data.selectedHeroes = data
	
	self:UpdateSelectedMission(missionId)
	
	--self.widget:CallFunction("setAssignedHero", index, missionId, hero)
end

return UserControlPanelScript
