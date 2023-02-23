local ElevatorScript = {}

-- Script properties are defined here
ElevatorScript.Properties = {
	-- Example property
	{ name = "startLocator", type = "entity" },
	{ name = "endLocationType", type = "string", options = { "entity", "z-value" }, default = "entity", tooltip = "The elevator can either move between the start position and an entity, or the start position and a specific z-value" },
	{ name = "endLocator", type = "entity", visibleIf = function(p) return p.endLocationType == "entity" end },
	{ name = "endZValue", type = "number", visibleIf = function(p) return p.endLocationType == "z-value" end, default = 0 },
	{ name = "elevatorPlatform", type = "entity" },
	{ name = "spool", type = "entity" },
	{ name = "delayedStart", type = "boolean", default = true, tooltip = "Wait a random amount of time before starting animations." },
	{ name = "speed", type = "number", default = 100 }
}

--This function is called on the server when this entity is created
function ElevatorScript:Init()
	local startPosition = self.properties.startLocator:GetPosition()
	local endPosition
	if self.properties.endLocationType == "z-value" then
		endPosition = Vector.New(startPosition.x, startPosition.y, self.properties.endZValue)
	else
		endPosition = self.properties.endLocator:GetPosition()
	end
	
	local distance = math.abs(endPosition.z - startPosition.z)
	local speed = distance / self.properties.speed
	
	
	local platform = self.properties.elevatorPlatform
	platform:SetPosition(endPosition)
	local position = "end"
	
	if self.properties.spool then 
		self:RunSpoolSchedule(speed)
	end
	
	
	self:Schedule(function()
		if self.properties.delayedStart then
			Wait(math.random() * 3)
		end
		
		while true do

			local newPos = Vector.New(startPosition.x, startPosition.y, startPosition.z)
			if position == "start" then
				position = "end"
				newPos.z = endPosition.z
			else
				position = "start"
				newPos.z = startPosition.z
			end
			if self.properties.endLocationType == "z-value" then
				print("Moving to", position, platform:GetPosition(), newPos, speed)
			end
			Wait(platform:PlayTimeline(
				0, platform:GetPosition(), "EaseInOut",
				speed, newPos, "EaseInOut"
			))
		end
	end)
end

function ElevatorScript:RunSpoolSchedule(speed)
	self:Schedule(function()
		while true do
			local rot = self.properties.spool:GetRotation()
			if position == "start" then
				rot.pitch = 360
			else
				rot.pitch = -360
			end
			
			Wait(self.properties.spool:PlayTimeline(
				0, self.properties.spool:GetRotation(), "EaseInOut",
				speed, rot, "EaseInOut"
			))
		end
	end)
end

return ElevatorScript
