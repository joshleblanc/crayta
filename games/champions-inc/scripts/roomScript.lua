local RoomScript = {}

-- Script properties are defined here
RoomScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "hasAssignedHero", type = "boolean", default = false, editable = false },
	{ name = "npcSpawn", type = "entity" },
	{ name = "trigger", type = "entity" },
	{ name = "roomCam", type = "entity" },
}

--This function is called on the server when this entity is created
function RoomScript:Init()
	self.properties.trigger.onTriggerEnter:Listen(self, "HandleTriggerEnter")
	self.properties.trigger.onTriggerExit:Listen(self, "HandleTriggerExit")
	
	self.widget = self:GetEntity():FindWidget("roomScreenWidget", true)
	
	--self:ActiveMissionSchedule()
end

function RoomScript:OnDestroy()
	if self.owner and Entity.IsValid(self.owner) then 
		self.owner.userRoomScript:UnsetRoom()
	end
	
	self:RemoveHero()
end

function RoomScript:OnRoomUpdated(room, user)
	if user ~= self.owner then return end
	if self.baseRoom.properties.id ~= room._id then return end
	
	print("Room updated", self.heroEntity and self.heroEntity:GetName(), room.assignedHero, self.baseRoom.properties.id, room._id)
	if not room.assignedHero then 
		self:RemoveHero()
	end
	
	if not room.activeMission then 
		GetWorld():BroadcastToScripts("OnMissionCompleted", self:GetEntity())
		self.activeMission = nil
		self.missionCompleteResult = nil 
		self.missionComplete = nil
		self.activeMissionTemplate = nil
	end
end


function RoomScript:SetBaseRoom(baseRoom)
	self.baseRoom = baseRoom
end

function RoomScript:RepositionHero()
	if self.heroEntity then 
		self.heroEntity:SetPosition(self.properties.npcSpawn:GetPosition())
	end
end

function RoomScript:SpawnHero(heroId, cb)
	self:Schedule(function()
		local db = self.owner.documentStoresScript.heroes
		local hero = db:FindOne({ _id = heroId })
		if not hero then return end 
		
		if self.heroEntity then 
			self.heroEntity:Destroy()
			self.heroEntity = nil
		end
		
		self.properties.hasAssignedHero = true 
		local template = GetWorld():FindTemplate(hero.templateName)
		self.heroEntity = GetWorld():Spawn(template, self.properties.npcSpawn:GetPosition(), self.properties.npcSpawn:GetRotation())

		Wait()
		
		self.heroEntity:SetPosition(self.properties.npcSpawn:GetPosition())
		self.heroEntity:SetRotation(self.properties.npcSpawn:GetRotation())
		
		Wait()
		
		self.heroEntity:SendToScripts("SetId", heroId)
		self.heroEntity:SendToScripts("SetOwner", self.owner)
		
		self.widget.properties.title = self.heroEntity.heroScript.properties.name
		
		if cb then 
			cb()
		end
	end)

end

function RoomScript:RemoveHero()
	print("Removing hero", self.heroEntity and self.heroEntity:GetName())
	if self.heroEntity then 
		self.heroEntity:Destroy()
		self.heroEntity = nil
	end
	
	self.properties.hasAssignedHero = false
end

function RoomScript:GetHeroEntity()
	return self.heroEntity
end

function RoomScript:SetOwner(owner)
	self.owner = owner

	
	self.owner.documentStoresScript:UseDb("rooms", function(db)
		local room = db:FindOne({ _id = self.baseRoom.properties.id })
		
		if room.assignedHero then 
			
			self:SpawnHero(room.assignedHero)
			
			self.activeMission = room.activeMission
			if self.activeMission then
				self.activeMissionTemplate = GetWorld():FindTemplate(room.activeMission.templateName)
				
				if GetWorld():GetUTCTime() < self.activeMission.endTime then 
					print("Broadcasting mission started")
					GetWorld():BroadcastToScripts("OnMissionStarted", self:GetEntity())
				end
				
			end	
		else 
			self.properties.hasAssignedHero = false
		end
	end)
end

function RoomScript:SetActiveMission(activeMission)
	self.activeMission = activeMission
	self.activeMissionTemplate = GetWorld():FindTemplate(activeMission.templateName)
	self:UpdateActiveMission()
end

function RoomScript:GetDoc()
	return self.owner.userRoomScript:GetRoom(self.baseRoom.properties.id)
end

function RoomScript:UpdateRoom(id, query)
	self.owner.userRoomScript:UpdateRoom(id, query)
end

function RoomScript:RemoveMission()
	self.activeMission = nil
	self.missionCompleteResult = nil 
	self.missionComplete = nil
	self.activeMissionTemplate = nil

	self:UpdateRoom(self.baseRoom.properties.id, {
		_unset = {
			activeMission = true
		}
	})
end


function RoomScript:HandleTriggerEnter(player)
	if player and player:IsA(Character) then 
		self:UpdateActiveMission()
		player:GetUser().userRoomScript:SetRoom(self)
	end
end

function RoomScript:HandleTriggerExit(player)
	if player and player:IsA(Character) then 
		
		player:GetUser().userRoomScript:UnsetRoom()
	end
end

function RoomScript:ShowWidget()
	if self.owner then 
		self.owner.userRoomScript:ShowWidget()
	end
end

return RoomScript
