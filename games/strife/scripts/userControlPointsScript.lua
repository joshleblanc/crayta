local UserControlPointsScript = {}

-- Script properties are defined here
UserControlPointsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function UserControlPointsScript:LocalInit()
	self.widget = self:GetEntity().userControlPointsWidget
	
	local capturePoints = GetWorld():FindAllScripts("controlPointScript")
	
	self.data = {}
	for _, point in ipairs(capturePoints) do 
		if point.properties.canCapture then 
			table.insert(self.data, point:ToTable())
		end
	end
	
	table.sort(self.data, function(a,b) return a.id < b.id end)
	
	self.widget.js.data.points = self.data
end

function UserControlPointsScript:Reset()
	if IsServer() then 
		self:SendToLocal("Reset")
		return
	end
	
	self.widget:Show()
	
	--[[
	for _, target in ipairs(self.data) do 
		target.pulse = false 
		target.owner = 0
	end
	
	self.widget.js.data.points = self.data
	--]]
	self:LocalInit()
end

function UserControlPointsScript:HandleCapture(id, team)
	if IsServer() then 
		self:SendToLocal("HandleCapture", id, team)
		return
	end
	
	for _, target in ipairs(self.data) do 
		if target.id == id then 
			target.owner = team
			target.pulse = false
		end
	end
	
	self.widget.js.data.points = self.data
end

function UserControlPointsScript:HandleLost(id, team)

	print("Handling lost control point", id, team)
	if IsServer() then 
		self:SendToLocal("HandleLost", id, team)
		return
	end
	
	for _, target in ipairs(self.data) do 
		if target.id == id then 
			target.owner = 0
			target.pulse = false
		end
	end
	
	self.widget.js.data.points = self.data
end

function UserControlPointsScript:HandleStopCapturing(id, team)
	if IsServer() then 
		self:SendToLocal("HandleStopCapturing", id, team)
		return
	end
		
	for _, target in ipairs(self.data) do 
		if target.id == id then 
			target.pulse = false
		end
	end
	
	self.widget.js.data.points = self.data
end

function UserControlPointsScript:HandleCapturing(id, team)
	if IsServer() then 
		self:SendToLocal("HandleCapturing", id, team)
		return
	end
		
	for _, target in ipairs(self.data) do 
		if target.id == id then 
			target.pulse = true
		end
	end
	
	self.widget.js.data.points = self.data
end

return UserControlPointsScript
