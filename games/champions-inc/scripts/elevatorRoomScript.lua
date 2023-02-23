local ElevatorRoomScript = {}

-- Script properties are defined here
ElevatorRoomScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "elevator", type = "entity" },
	{ name = "bridge", type = "entity" },
	{ name = "bridgeEffects", type = "entity" },
	{ name = "bridgeEffectsPost", type = "entity" },
	{ name = "elevatorEffects", type = "entity" },
	{ name = "door", type = "entity" }
}

--This function is called on the server when this entity is created
function ElevatorRoomScript:Init()
	self.startingBridgeRotation = self.properties.bridge:GetRelativeRotation()
	self.startingElevatorPosition = self.properties.elevator:GetRelativePosition()
end

function ElevatorRoomScript:OnMissionCompleted(roomEntity)
	if roomEntity ~= self:GetEntity() then return end 
	
	print("Room running completed schedule")
	
	if self.completedSchedule then 
		self:Cancel(self.completedSchedule)
		self.completedSchedule = nil
	end
	
	if self.startedSchedule then 
		self:Cancel(self.startedSchedule)
		self.startedSchedule = nil
	end
	
	self.completedSchedule = self:Schedule(function()
		local effects = self.properties.bridgeEffects:GetChildren()
		local postEffects = self.properties.bridgeEffectsPost:GetChildren()
		local elevatorEffects = self.properties.elevatorEffects:GetChildren()
		
		print(#effects, #postEffects, #elevatorEffects)
		
		local timeToRaiseElevator = self.properties.elevator:PlayRelativeTimeline(
			0, self.startingElevatorPosition - Vector.New(0, 0, 5000), "EaseInOut",
			7, self.startingElevatorPosition, "EaseInOut"
		)
		
		local timeToRaiseBridge = self.properties.bridge:PlayRelativeTimeline(
			0, Rotation.New(-90, 0, 0), "EaseInOut",
			5, self.startingBridgeRotation, "EaseInOut"
		)
		
		for i=1,#effects do 
			effects[i].active = true
		end
		
		for i=1,#elevatorEffects do 
			elevatorEffects[i].active = true
		end
		
		
		Wait()
		
		roomEntity:SendToScripts("RepositionHero")
		
		Wait(timeToRaiseBridge)
		
		for i=1,#effects do 
			print("turning off effect",effects[i]:GetName())
			effects[i].active = false
		end
		
		for i=1,#postEffects do 
			postEffects[i].active = true
		end
		
		Wait(timeToRaiseElevator - timeToRaiseBridge)
		
		for i=1,#postEffects do 
			postEffects[i].active = false
		end
		
		for i=1,#elevatorEffects do 
			elevatorEffects[i].active = false
		end
		
		self.properties.door:PlayAnimation("Opening")

	end)
end

function ElevatorRoomScript:OnMissionStarted(roomEntity)
	if roomEntity ~= self:GetEntity() then return end 
	print("Room running started  schedule")
	if self.completedSchedule then 
		self:Cancel(self.completedSchedule)
		self.completedSchedule = nil
	end
	
	if self.startedSchedule then 
		self:Cancel(self.startedSchedule)
		self.startedSchedule = nil
	end
	
	self.startedSchedule = self:Schedule(function()
		self.properties.door:PlayAnimation("Closing")
		local timeToLowerBridge = self.properties.bridge:PlayRelativeTimeline(
			0, self.properties.bridge:GetRelativeRotation(), "EaseInOut",
			5, Rotation.New(-90, 0, 0), "EaseInOut"
		)
		
		local effects = self.properties.bridgeEffects:GetChildren()
		local postEffects = self.properties.bridgeEffectsPost:GetChildren()
		local elevatorEffects = self.properties.elevatorEffects:GetChildren()
		
		for i=1,#effects do 
			effects[i].active = true
		end
		
		Wait(timeToLowerBridge - 2)
		
		for i=1,#effects do 
			effects[i].active = false
		end
		
		for i=1,#postEffects do 
			postEffects[i].active = true
		end
		
		local timeToLowerElevator = self.properties.elevator:PlayRelativeTimeline(
			0, self.properties.elevator:GetRelativePosition(), "EaseInOut",
			7, self.properties.elevator:GetRelativePosition() - Vector.New(0, 0, 5000), "EaseInOut"
		)
		
		for i=1,#elevatorEffects do 
			elevatorEffects[i].active = true
		end
		
		Wait(timeToLowerElevator)
		
		Wait()
		
		roomEntity:SendToScripts("RepositionHero")
		
		for i=1,#postEffects do 
			postEffects[i].active = false
		end
		
		for i=1,#elevatorEffects do 
			elevatorEffects[i].active = false
		end
	end)
end

return ElevatorRoomScript
