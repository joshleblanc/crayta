local UserRoomScript = {}

-- Script properties are defined here
UserRoomScript.Properties = {
	-- Example property
	{name = "confirmButtonSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function UserRoomScript:Init()
	self.widget = self:GetEntity().userRoomWidget
	self.detailsWidget = self:GetEntity().userRoomDetailsWidget
	self.heroSelectWidget = self:GetEntity().heroSelectWidget
	self.heroMergeWidget = self:GetEntity().heroMergeWidget
	self.userRoomMissionsWidget = self:GetEntity().userRoomMissionsWidget
	
	self:CloseAll()
	
	self.heroesScript = self:GetEntity().userHeroesScript
	self.db = self:GetEntity().documentStoresScript
	
	self.db:UseDb("rooms", function(db)
		db:DeleteMany()
	end)
	
	--self:ActiveMissionSchedule()
	--self:MiaSchedule()
	
	--[[
	self.db:UseDb("rooms", function(roomsDb)
		self.db:UseDb("heroes", function(heroesDb)
			local rooms = roomsDb:Find()
			for _, room in ipairs(rooms) do 
				if room.activeMission and room.activeMission.mission then 
					local hero = heroesDb:FindOne({ _id = room.activeMission.mission.heroId })
					if not hero then 
						self:GetEntity().userHeroesScript:RemoveHero(room.activeMission.mission.heroId)
					end
				end
				
				if room.assignedHero then 
					local hero = heroesDb:FindOne({ _id = room.assignedHero })
					if not hero then 
						self:GetEntity().userHeroesScript:RemoveHero(room.assignedHero)
					end
				end
			end
		end)
	end)
	]]--
end

function UserRoomScript:UpdateRoom(id, query)
	local room = self.db.rooms:UpdateOne({ _id = id }, query)
	
	GetWorld():BroadcastToScripts("OnRoomUpdated", room, self:GetEntity())
	
	return room
end

function UserRoomScript:GetRoom(id)
	return self.db.rooms:FindOne({ _id = id })
end

function UserRoomScript:MiaSchedule()
	self:Schedule(function()
		while true do 	
			Wait(1)
			self:UpdateMiaStatus()
		end
	end)
end

function UserRoomScript:UpdateMiaStatus() 
	local heroEntity = self:GetHeroEntity()

	if self.room and heroEntity then 
		self.widget.properties.isMia = self.heroesScript:IsMia(self:GetHeroId())
		self.widget.properties.miaRemaining = self.heroesScript:MiaRemaining(self:GetHeroId())
		self.widget.properties.miaInstructions = Text.Format("Rescue your hero using the Rescue {1} mission or wait for them to recover", self.room.heroEntity:FindScriptProperty("name"))
	end
end

function UserRoomScript:ActiveMissionSchedule() 
	self:Schedule(function()
		while true do 
			Wait(1)
			
			self:UpdateActiveMission()
		end
	end)
end

function UserRoomScript:UpdateActiveMission()
	if self.room and self.room.activeMission and self.room.timeLeft then 
		self.widget.properties.inProgressTimeLeft = Text.FormatTime("{hh}:{mm}:{ss}", self.room.timeLeft)
		self.widget.properties.inProgress = true
		self.widget.properties.inProgressComplete = self.room.missionComplete
		self.widget.properties.inProgressResult = self.room.missionCompleteResult
		self.widget.properties.inProgressMission = self.room.activeMissionTemplate:FindScriptProperty("name")
	else
		self.widget.properties.inProgress = false
	end
end

function UserRoomScript:OnRoomUpdated(room, user)
	if user ~= self:GetEntity() then return end
	if not self.room or not self.room.baseRoom.properties.id == room._id then return end
	
	self:UpdateActiveMission()
	self:UpdateRoomWidgetDetails()
end

function UserRoomScript:OnRecordUpdated(t, hero)
	if t ~= "heroes" then return end
	if hero._id ~= self:GetHeroId() then return end 
	
	self:UpdateAllWidgets()
end

function UserRoomScript:UpdateAllWidgets()
	self:Schedule(function()
		self:UpdateDetails()
		Wait()
		self:UpdateMiaStatus()
		Wait()
		self:UpdateActiveMission()
		Wait()
		self:UpdateRoomWidgetDetails()
		Wait()
	end)
end

function UserRoomScript:UpdateDetailsForHero(heroEntity, heroId)
	self.detailsWidget.properties.heroName = heroEntity:FindScriptProperty("name")
	self.detailsWidget.properties.heroDescription = heroEntity:FindScriptProperty("description")
	self.detailsWidget.properties.weight = heroEntity:FindScriptProperty("weight")
	self.detailsWidget.properties.rarity = heroEntity.heroScript:GetRarity()
	self.detailsWidget.properties.heroXp = self:GetEntity().userHeroesScript:GetXp(heroId)
	self.detailsWidget.properties.heroXpPercent = self:GetEntity().userHeroesScript:GetXpPercent(heroId)
	self.detailsWidget.properties.heroXpRequired = self:GetEntity().userHeroesScript:GetXpRequired(heroId)
	self.detailsWidget.properties.heroLevel = self:GetEntity().userHeroesScript:GetLevel(heroId)
	self.detailsWidget.properties.heroAvailable = self:GetEntity().userHeroesScript:IsAvailable(heroId)
	self.detailsWidget.properties.heroHealthPercent = self:GetEntity().userHeroesScript:GetHealthPercent(heroId)
	 
	self.widget.properties.hero = heroEntity:FindScriptProperty("name")
	self.widget.properties.heroDescription = heroEntity:FindScriptProperty("description")
	
	print("Setting stats")
	self:SetRoomStats(heroEntity.heroScript:StatWidgetData())
	
	local str = self:GetEntity().userHeroesScript:GetStatLevel(heroId, "strength")
	local int = self:GetEntity().userHeroesScript:GetStatLevel(heroId, "intelligence")
	
	self:SetMissions(self:GetEntity().availableMissionsScript:GetMissionsWidgetData(str, int))
	self:UpdateMiaStatus()
	self:UpdateActiveMission()
end

function UserRoomScript:UpdateDetails()
	local heroEntity = self:GetHeroEntity()
	local heroId = self:GetHeroId()
	
	if not heroEntity then return end 
	
	self:UpdateDetailsForHero(heroEntity, heroId)
	
	print("Updating details", heroEntity:FindScriptProperty("name"), heroId)
	

end

function UserRoomScript:UpdateRoomWidgetDetails()
	if not self.room then return end 
	
	if self.room.baseRoom then 
		self.widget.properties.name = self.room.baseRoom.properties.name
		self.widget.properties.description = self.room.baseRoom.properties.description
	end

	print("Updating room widget details", self.room.properties.hasAssignedHero)
	if self.room.properties.hasAssignedHero then 
		self.widget.properties.buttonText = Text.Format("({interact-icon-raw}) Select Mission")
	else
		self.widget.properties.buttonText = Text.Format("({interact-icon-raw}) Assign Hero")
	end
end

function UserRoomScript:CloseAll()
	if not IsServer() then 
		self:SendToServer("CloseAll")
		return
	end
	
	self.open = false 
	self.selectionOpen = false
	self.detailsOpen = false
	self.missionsOpen = false
	self.mergeOpen = false

	self.widget:Hide()
	self.heroSelectWidget:Hide()
	self.detailsWidget:Hide()
	self.heroMergeWidget:Hide()
	self.userRoomMissionsWidget:Hide()
end

function UserRoomScript:RoomSelectHeroForMerge(heroId)
	if not IsServer() then 
		self:SendToServer("SelectHeroForMerge", heroId)
		return
	end
	
	local roll = math.random()
	local weight = self:GetHeroEntity():FindScriptProperty("weight")
	if roll >= 0.5 then 
		weight = self:GetHeroEntity().heroScript:GetNextWeight(weight)
	end
	
	local newHero = self:GetEntity().userHeroesScript:GetNewHeroForWeight(weight)
	
	self:GetEntity():SendXPEvent("merge-hero")
		
	self:GetEntity().userHeroesScript:RemoveHero(heroId)
	self:GetEntity().userHeroesScript:RemoveHero(self:GetHeroId())
	
	self:GetEntity().availableMissionsScript:RemoveMia(heroId)
	self:GetEntity().availableMissionsScript:RemoveMia(self:GetHeroId())
	
	self:GetEntity().availableMissionsScript:EnsureMinimumMissions()
	
	local newHeroEntity = GetWorld():Spawn(newHero, Vector.Zero, Rotation.Zero)
	local newHeroDoc = self:GetEntity().userHeroesScript:AddHero(newHeroEntity.heroScript)
	
	if newHeroEntity.heroScript:GetRarity() == "Legendary" then 
		self:GetEntity():AddToLeaderboardValue("number-legendaries", 1)
	end
	
	newHeroEntity:Destroy()
	
	self:AssignToRoom(newHeroDoc._id)
	
	self:CloseAll()
end

function UserRoomScript:OpenMergeWidget()
	if not IsServer() then 
		self:SendToServer("OpenMergeWidget")
		return
	end
	
	self:CloseAll()
	
	local rarity = self:GetHeroEntity():FindScriptProperty("weight")
	local widgetData = self:GetEntity().userHeroesScript:GetHeroesOfRarity(rarity)
	
	local newData = {}
	
	-- remove self
	for _, d in ipairs(widgetData) do 
		if d.id ~= self:GetHeroId() then 
			table.insert(newData, d)
		end
	end
	
	self:SetMergeHeroes(newData)
	
	self:CloseAll()
	self.mergeOpen = true
	self.heroMergeWidget:Show()
end

function UserRoomScript:ShowWidget()
	self:CloseAll()
	self.widget:Show()
	self.open = true
end

function UserRoomScript:SetRoom(room)
	self.room = room
	
	self:UpdateRoomWidgetDetails()
	
	self:CloseAll()
	if room and room.properties.hasAssignedHero then 
		self:UpdateDetails()
		self.open = true
		self.widget:Show()
	end
end

function UserRoomScript:CloseDetailsWidget()
	if not IsServer() then 
		self:SendToServer("CloseDetailsWidget")
		return
	end
	
	self.detailsOpen = false
	self.missionsOpen = false
	self:SetRoom(self.room)
end

function UserRoomScript:UnsetRoom()
	self.open = false
	self.detailsOpen = false
	self.selectionOpen = false
	self.room = nil
	self.widget:Hide()
end

function UserRoomScript:GetHeroEntity()
	if not self.room then return end 
	
	return self.room:GetHeroEntity()
end

function UserRoomScript:GetHeroId()
	local hero = self:GetHeroEntity()
	if hero then 
		return hero:FindScriptProperty("id")
	else 
		return nil
	end
end

function UserRoomScript:StartMission(missionId)
	if not IsServer() then 
		self:SendToServer("StartMission", missionId)
		return
	end
	
	self:GetEntity().documentStoresScript:UseDb("availableMissions", function(availableMissionsDb)
		local missionDoc = availableMissionsDb:FindOne({ _id = missionId })
		local template = GetWorld():FindTemplate(missionDoc.templateName)
		
		local heroId = self:GetHeroEntity().heroScript.properties.id
		
		local duration = template:FindScriptProperty("duration") * 60
		local intelligence = self:GetEntity().userHeroesScript:GetStatLevel(heroId, "intelligence")
		local strength = self:GetEntity().userHeroesScript:GetStatLevel(heroId, "strength")
		
		duration = self:GetEntity().userHeroesScript:CalcDuration(duration, intelligence)
		
		local endTime = GetWorld():GetUTCTime() + duration
		
		self.widget.properties.inProgress = true
		self.widget.properties.inProgressComplete = false
		self.widget.properties.inProgressResult = nil
		self.widget.properties.inProgressMission = template:FindScriptProperty("name")
		self.widget.properties.inProgressTimeLeft = Text.FormatTime("{hh}:{mm}:{ss}", endTime - GetWorld():GetUTCTime())
		
		local room = self:UpdateRoom(self.room.baseRoom.properties.id, {
			_set = {
				activeMission = {
					id = missionId,
					templateName = template:GetName(),
					startTime = GetWorld():GetUTCTime(),
					endTime = endTime,
					mission = self:GetEntity().availableMissionsScript:GetMissionWidgetData(missionDoc, strength, intelligence)
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

function UserRoomScript:ResetSelectWidget()
	if IsServer() then 
		self:GetEntity():SendToLocal("ResetSelectWidget")
		return
	end
	self:GetEntity().heroSelectWidget.js:CallFunction("Reset")
end

function UserRoomScript:OnButtonPressed(btn)
	if self.selectionOpen then return end 
	
	if self.open and btn == "extra1" and not self.room.activeMission then 
		local heroes = self:GetEntity().userHeroesScript:GetHeroesWidgetData()
		--self:SetHeroes(heroes)
	
		self:CloseAll()
		--self:UpdateAllWidgets()
		self.selectionOpen = true
		--self:ResetSelectWidget()
		--self.heroSelectWidget:Show()
		
		if #heroes > 0 then 
			self:GetEntity().userHeroSelectScript:RunHeroSelect(self.room.baseRoom:GetEntity():GetParent():GetParent().baseScript.properties.heroSelect.heroSelectScript)
		end
	end
	
	if self.open and btn == "interact" then 
		local heroEntity = self:GetHeroEntity()
		local heroId = heroEntity and heroEntity:FindScriptProperty("id")
		
		if heroEntity and self.heroesScript:IsMia(self:GetHeroId()) then 
			print("Hero mia, returning early")
			return
		end
		
		if self.room.missionComplete then 
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
		elseif not self.room.activeMission then
			self.widget:Hide()
			self.open = false
			
			if self.room.properties.hasAssignedHero then
				self:UpdateDetails()

				self:CloseAll()
				
				self:OpenFullDetails()
			else 
				local heroes = self:GetEntity().userHeroesScript:GetHeroesWidgetData()
				
				if #heroes > 0 then 
					self:SetHeroes(heroes)
					
					self:CloseAll()
					self.selectionOpen = true
				--	self:ResetSelectWidget()
				--	self.heroSelectWidget:Show()
					self:GetEntity().userHeroSelectScript:RunHeroSelect(self.room.baseRoom:GetEntity():GetParent():GetParent().baseScript.properties.heroSelect.heroSelectScript)

				end
			end
		end
	end
end

function UserRoomScript:CloseSelectionWidget()
	if not IsServer() then 
		self:SendToServer("CloseSelectionWidget")
		return
	end
	self:CloseAll()
	self.widget:Show()
	self.open = true
end

function UserRoomScript:OpenDetails(opts)
	opts = opts or { mode = "merge" }
	
	self.detailsWidget.properties.mode = opts.mode
	
	self.detailsWidget:Show()
	self.detailsOpen = true
end

function UserRoomScript:OpenMissions()
	self.missionsOpen = true
	self.userRoomMissionsWidget:Show()
end

function UserRoomScript:OpenFullDetails()
	self:UpdateAllWidgets()
	
	self:OpenDetails()
	self:OpenMissions()
end

function UserRoomScript:CloseMergeWidget()
	if not IsServer() then 
		self:SendToServer("CloseMergeWidget")
		return
	end
	
	self:CloseAll()
	
	
	self:OpenFullDetails()
end

function UserRoomScript:SelectHeroForRoom(id)
	if not IsServer() then 
		self:SendToServer("SelectHeroForRoom", id)
		return
	end
	
	self:AssignToRoom(id)
end

function UserRoomScript:AssignToRoom(id)
	self:GetEntity().userHeroesScript:AssignToRoom(id, self.room.baseRoom.properties.id)
	
	self.room:SpawnHero(id, function()
		self:SetRoom(self.room)

		self:UpdateAllWidgets()	
		
		self:CloseAll()
		
		self:ShowWidget()
	end)
end

function UserRoomScript:SetMissions(missions)
	if IsServer() then 

		self:SendToLocal("ClearMissionsWidget")
		for _, mission in ipairs(missions) do 
			self:SendToLocal("SendMissionToWidget", mission)
		end
		self:SendToLocal("FinalizeMissionSend")
		--self:SendToLocal("SetHeroes", heroes)
		return
	end
end

function UserRoomScript:ClearMissionsWidget()
	self:GetEntity().userRoomMissionsWidget:CallFunction("ClearMissions")
end

function UserRoomScript:SendMissionToWidget(mission)
	self:GetEntity().userRoomMissionsWidget:CallFunction("AddMission", mission)
end

function UserRoomScript:FinalizeMissionSend()
	self:GetEntity().userRoomMissionsWidget:CallFunction("FinalizeMissions")
end

function UserRoomScript:SetMergeHeroes(heroes)
	if IsServer() then 
		self:GetEntity().heroMergeWidget.properties.noOptions = #heroes == 0
		
		self:SendToLocal("ClearMergeWidget")
		for _, hero in ipairs(heroes) do 
			self:SendToLocal("SendHeroToMergeWidget", hero)
		end
		self:SendToLocal("FinalizeMergeSend")
		--self:SendToLocal("SetHeroes", heroes)
		return
	end
end

function UserRoomScript:SetHeroes(heroes)
	if IsServer() then 
		self:GetEntity().heroSelectWidget.properties.noOptions = #heroes == 0
		
		self:SendToLocal("ClearHeroesWidget")
		for _, hero in ipairs(heroes) do 
			self:SendToLocal("SendHeroToWidget", hero)
		end
		self:SendToLocal("FinalizeHeroSend")
		--self:SendToLocal("SetHeroes", heroes)
		return
	end
	
	
	--self:GetEntity().heroSelectWidget:CallFunction("SetHeroes", heroes)
end

function UserRoomScript:ClearMergeWidget()
	self:GetEntity().heroMergeWidget:CallFunction("ClearHeroes")
end

function UserRoomScript:FinalizeMergeSend()
	self:GetEntity().heroMergeWidget:CallFunction("FinalizeHeroes")
end

function UserRoomScript:SendHeroToMergeWidget(hero)
	self:GetEntity().heroMergeWidget:CallFunction("AddHero", hero)
end

function UserRoomScript:SetHeroes(heroes)
	if IsServer() then 
		self:GetEntity().heroSelectWidget.properties.noOptions = #heroes == 0
		
		self:SendToLocal("ClearHeroesWidget")
		for _, hero in ipairs(heroes) do 
			self:SendToLocal("SendHeroToWidget", hero)
		end
		self:SendToLocal("FinalizeHeroSend")
		--self:SendToLocal("SetHeroes", heroes)
		return
	end
	
	
	--self:GetEntity().heroSelectWidget:CallFunction("SetHeroes", heroes)
end

function UserRoomScript:ClearHeroesWidget()
	self:GetEntity().heroSelectWidget:CallFunction("ClearHeroes")
end

function UserRoomScript:FinalizeHeroSend()
	self:GetEntity().heroSelectWidget:CallFunction("FinalizeHeroes")
end

function UserRoomScript:SendHeroToWidget(hero)
	self:GetEntity().heroSelectWidget:CallFunction("AddHero", hero)
end

function UserRoomScript:SetRoomStats(stats)
	if IsServer() then 
		print("Sending heroscript to local", stats)
		self:SendToLocal("SetRoomStats", stats)
		return
	end
	
	print("Setting stats", stats)
	if not stats then return end 
	
	self:GetEntity().userRoomDetailsWidget.js.data.stats = stats
end

return UserRoomScript
