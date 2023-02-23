local ControlPointScript = {}

-- Script properties are defined here
ControlPointScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "owner", type = "number", default = 0},
	{ name = "canCapture", type = "boolean", default = true },
	{ name = "capturingTeam", type = "number", default = 0, editable = false },
	{ name = "numTeams", type = "number", default = 2 },
	{ name = "name", type = "string" },
	{ name = "timeToCapture", type = "number" },
	{ name = "id", type = "string" },
	{ name = "onCapture", type = "event", group = "events" },
	{ name = "onLost", type = "event", group = "events" },
	{ name = "onCapturing", type = "event", group = "events" },
	{ name = "onStopCapturing", type = "event", group = "events" },
	{ name = "trigger", type = "entity" }
}

--This function is called on the server when this entity is created
function ControlPointScript:Init()
	self.scores = {}
	if self.properties.canCapture then 
		self.properties.owner = 0
		self.properties.onCapture:Send(self.properties.id, self.properties.owner)
	else
		self.properties.onCapture:Send(self.properties.id, self.properties.owner)
	end
	
	self.properties.capturingTeam = 0
	
	for i=1,self.properties.numTeams do 
		self.scores[i] = 0
	end
	
	self.proximityTrigger = self.properties.trigger:FindScript("rangeIndicatorScript") 
end

function ControlPointScript:ToTable()
	return {
		owner = self.properties.owner,
		canCapture = self.properties.canCapture,
		capturingTeam = self.properties.capturingTeam,
		numTeam = self.properties.numTeams,
		name = self.properties.name,
		timeToCapture = self.properties.timeToCapture,
		id = self.properties.id
	}
end

function ControlPointScript:Reset()
	self:Init()
end

function ControlPointScript:IsNeutral()
	local sum = 0
	
	for i=1,self.properties.numTeams do 
		sum = sum + self.scores[i]
	end
	
	return (sum - self.scores[self.properties.capturingTeam]) == 0
end

function ControlPointScript:GetTeam(n)
	if n == 1 then 
		return "Knights"
	else 
		return "Sorcerers"
	end
end

function ControlPointScript:OnTick(dt)
	if not self.properties.canCapture then return end 
	
	local inc = dt * self.properties.timeToCapture
	--print(self.properties.owner, self.properties.capturingTeam)
	if self.properties.capturingTeam == 0 then return end 
	
	-- If the capturing team already owns the point, we have nothing to do 
	if self.scores[self.properties.capturingTeam] == 100 then 
		return
	end
	
	-- If the point is neutral, we can start giving control to the capturing team
	if self:IsNeutral() then
		self.scores[self.properties.capturingTeam] = math.min(100, self.scores[self.properties.capturingTeam] + inc)
		
		-- if the capturing team owns the point after this tick, we have a new owner
		if self.scores[self.properties.capturingTeam] == 100 then 
			self.properties.owner = self.properties.capturingTeam
			self.properties.onCapture:Send(self.properties.id, self.properties.capturingTeam)
			
			local capturingPlayers = self.proximityTrigger.counts[self.properties.capturingTeam]
			for _, player in ipairs(capturingPlayers) do 
				if player:IsValid() and player:IsAlive() then 
					player:GetUser():SendXPEvent("capture-point")
					player:GetUser():SendToScripts("AddCapture")
				end
			end
			
			self:Notify("{1} have captured {2}", self:GetTeam(self.properties.owner), self.properties.name)
		end
	else -- otherwise, we need to make it neutral
		for i=1,self.properties.numTeams do 
			self.scores[i] = math.max(0, self.scores[i] - inc)
		end
		
		-- if this tick made it neutral, and there was a previous owner, announce the point has been lost
		if self:IsNeutral() and self.properties.owner > 0 then 
			self.properties.onLost:Send(self.properties.id, self.properties.owner)
			self:Notify("{1} have lost {2}", self:GetTeam(self.properties.owner), self.properties.name)
			self.properties.owner = 0
		end
	end
end

-- The trigger indicates which team has the most players inside the 
-- trigger
function ControlPointScript:HandleProximityOwnerChange(owner)
	if not self.properties.canCapture then return end 
	
	if self.properties.capturingTeam ~= owner then 
		self.properties.capturingTeam = owner
		if owner ~= 0 and self.properties.capturingTeam ~= self.properties.owner then 
			self:Notify("{1} are capturing {2}", self:GetTeam(owner), self.properties.name)
			self.properties.onCapturing:Send(self.properties.id, self.properties.capturingTeam)
		end
	end
	
	if owner == 0 then 
		self.properties.onStopCapturing:Send(self.properties.id, self.properties.capturingTeam)
	end
end

function ControlPointScript:Notify(msg, team, name)
	GetWorld():ForEachUser(function(user)
		user:SendToScripts("Shout", FormatString(msg, team, name))
	end)
end

return ControlPointScript
