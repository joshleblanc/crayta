local CablecarScript = {}

-- Script properties are defined here
CablecarScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "startLocation", type = "entity" },
	{ name = "endLocation", type = "entity" },
	{ name = "gears", type = "entity", container = "array" },
	{ name = "spools", type = "entity", container = "array" },
	{ name = "platform", type = "entity" },
	{ name = "speed", type = "number", default = 100 }
}

--This function is called on the server when this entity is created
function CablecarScript:Init()
	local startPos = self.properties.startLocation:GetPosition()
	local endPos = self.properties.endLocation:GetPosition()
	
	local dir = (endPos - startPos):Normalize()
	local offset = 250
	startPos = startPos + (dir * offset)
	endPos = endPos - (dir * offset)

	local distance = Vector.Distance(startPos, endPos)
	local speed = distance / self.properties.speed
	
	local position = "start"
	local platform = self.properties.platform
	
	platform:SetPosition(startPos)
	
	local originalRotation = platform:GetRotation()
	local newRotation = Rotation.FromVector((endPos - startPos):Normalize())
	newRotation.pitch = originalRotation.pitch
	platform:SetRotation(newRotation)
	
	for i=1,#self.properties.gears do 
		local gear = self.properties.gears[i]
		self:Schedule(function()
			while true do
				local rot = gear:GetRotation()
				if position == "start" then
					rot.pitch = 360
				else
					rot.pitch = -360
				end
				if i % 2 == 0 then
					rot.pitch = rot.pitch * -1
				end	
				Wait(gear:PlayTimeline(
					0, gear:GetRotation(), "EaseInOut",
					speed, rot, "EaseInOut"
				))
			end
		end)
	end
	
	for i=1,#self.properties.spools do 
		local spool = self.properties.spools[i]
		self:Schedule(function()
			while true do
				local rot = spool:GetRotation()
				if position == "start" then
					rot.yaw = 360
				else
					rot.yaw = -360
				end

				Wait(spool:PlayTimeline(
					0, spool:GetRotation(), "EaseInOut",
					speed, rot, "EaseInOut"
				))
			end
		end)
	end
	
	self:Schedule(function()
		while true do
			local newPos
			if position == "start" then
				position = "end"
				newPos = endPos
			else
				position = "start"
				newPos = startPos
			end
			
			Wait(platform:PlayTimeline(
				0, platform:GetPosition(), "EaseInOut",
				speed, newPos, "EaseInOut"
			))
		end
	end)
end

return CablecarScript
