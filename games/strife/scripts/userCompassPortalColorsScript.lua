local UserCompassPortalColorsScript = {}

-- Script properties are defined here
UserCompassPortalColorsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserCompassPortalColorsScript:LocalInit()
	local points = GetWorld():FindAllScripts("controlPointScript")
	
	self.targets = self:GetEntity():FindAllScripts("compassTargetScript")
	
	self.points = {}
	for _, point in ipairs(points) do 
		self.points[point.properties.id] = point
	end
end

function UserCompassPortalColorsScript:Reset()
	if IsServer() then 
		self:SendToLocal("Reset")
		return
	end
	
	for _, target in ipairs(self.targets) do 
		if target.properties.id ~= "knight-spawn" and target.properties.id ~= "sorcerer-spawn" then 
			target.properties.pulse = false 
			target.properties.color = Color.New(1,1,1)
		end
		
	end
end

function UserCompassPortalColorsScript:HandleCapture(id, team)
	if IsServer() then 
		self:SendToLocal("HandleCapture", id, team)
		return
	end
	

	if type(team) == "number" then 
		team = id 
		id = "payload"
		for _, target in ipairs(self.targets) do 
			if target.properties.id == id then 
				if team == 1 then 
					target.properties.color = Color.New(53 / 255, 218 / 255, 171 / 255)
				elseif team == 2 then
					target.properties.color = Color.New(178 / 255, 152 / 255, 252 / 255)
				else 
					target.properties.color = Color.New(1, 1, 1)
				end
				target.properties.pulse = false
			end
		end
	else
		local point = self.points[id]
		if not point then return end 
		
		print("Coloring", id, team)
		for _, target in ipairs(self.targets) do 
			if target.properties.id == point.properties.id then 
				print("Found", id, team)
				if team == 1 then 
					print("Setting to green")
					target.properties.color = Color.New(53 / 255, 218 / 255, 171 / 255)
				elseif team == 2 then
					target.properties.color = Color.New(178 / 255, 152 / 255, 252 / 255)
				else 
					target.properties.color = Color.New(1, 1, 1)
				end
				target.properties.pulse = false
			end
		end
	end
end

function UserCompassPortalColorsScript:HandleLost(id, team)
	if IsServer() then 
		self:SendToLocal("HandleLost", id, team)
		return
	end
	local point = self.points[id]
	
	for _, target in ipairs(self.targets) do 
		if target.properties.id == point.properties.id then 
			target.properties.color = Color.New(1, 1, 1)
			target.properties.pulse = false
		end
	end
end

function UserCompassPortalColorsScript:HandleStopCapturing(id, team)
	if IsServer() then 
		self:SendToLocal("HandleStopCapturing", id, team)
		return
	end
	
	local point = self.points[id]
	
	for _, target in ipairs(self.targets) do 
		if target.properties.id == point.properties.id then 
			target.properties.pulse = false
		end
	end
end

function UserCompassPortalColorsScript:HandleCapturing(id, team)
	if IsServer() then 
		self:SendToLocal("HandleCapturing", id, team)
		return
	end
	
	print("Capturing", id, team)
	local point = self.points[id]
	
	for _, target in ipairs(self.targets) do 
		if target.properties.id == point.properties.id then 
			print("Setting pulse to true")
			target.properties.pulse = true
		end
	end
end

return UserCompassPortalColorsScript
