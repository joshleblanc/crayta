local PayloadProgressScript = {}

-- Script properties are defined here
PayloadProgressScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
 	{ name = "start", type = "entity" },
 	{ name = "vehicle", type = "entity" }
}

-- This will only be called on the user
function PayloadProgressScript:LocalInit()
	self.widget = self:GetEntity().payloadProgressWidget
	self.system = GetWorld():FindScript("TWSystem")
	
	self:FetchTransform()
	self:FetchTrackLength()
	
	--self:CalcProgress()
	self:Schedule(function()
		while true do 
			local progress = self:CalcProgress()
			self.widget.js.data.progress = FormatString("{1}%", 100 - progress)
			
			Wait()
		end
	end)
end

function PayloadProgressScript:Init()
	self.system = GetWorld():FindScript("TWSystem")
	
	self:FetchTransform()
	self:FetchTrackLength()
end

function PayloadProgressScript:OnTick()
	local progress = self:CalcProgress()
	local team
	if progress < 50 then 
		team = 1
		self:GetEntity():SendToScripts("SetTeamScore", 1, math.floor(50 - progress))
		self:GetEntity():SendToScripts("SetTeamScore", 2, 0)
	elseif progress > 50 then
		team = 2
		self:GetEntity():SendToScripts("SetTeamScore", 1, 0)
		self:GetEntity():SendToScripts("SetTeamScore", 2, math.floor(progress - 50))
	else
		self:GetEntity():SendToScripts("SetTeamScore", 1, 0)
		self:GetEntity():SendToScripts("SetTeamScore", 2, 0)
	end
	
end

function PayloadProgressScript:CalcProgress()
	local left = 0
	
	local state = self.transform:GetState()
	
	local track
	while state.outOfTrack ~= true do 
		if state.track ~= track then 
			left = left + state.track:GetLength()
		end
		
		track = state.track
		
		state = self.transform:CalculateMovementState(100 * state.tDirection, state)
	end
	
	local currState = self.transform:GetState()
	
	local currLeft = currState.track:GetLength() * currState.t
	
	return ((((self.totalLength - left) + (currLeft * currState.tDirection))) / self.totalLength) * 100
end

function PayloadProgressScript:FetchTransform()
	self.vehicle = self.properties.vehicle:FindScript("TWVehicle")
	self.transform = self.vehicle:GetEntity().TWTransform
end

function PayloadProgressScript:FetchTrackLength()
	local tracks = GetWorld():FindAllScripts("TWTrackSection")
	self.totalLength = 0

	for _, track in ipairs(tracks) do 
		local proto = self.system:GetTrackPrototype(track:GetKey())
		print(proto:GetPath():GetLength(), track:GetEntity():GetName())
		self.totalLength = self.totalLength + proto:GetPath():GetLength()
	end
end

function PayloadProgressScript:HandleOwnerChange(owner, num1, num2)
	self:SendToLocal("LocalHandlerOwnerChange", owner, num1, num2)
end

function PayloadProgressScript:LocalHandlerOwnerChange(owner, num1, num2)
	self.widget:CallFunction("UpdateIcon", owner, num1, num2)
end

function PayloadProgressScript:Show()
	self.widget:Show()
end

function PayloadProgressScript:Hide()
	self.widget:Hide()
end

return PayloadProgressScript
