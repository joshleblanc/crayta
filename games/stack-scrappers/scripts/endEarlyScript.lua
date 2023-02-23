local EndEarlyScript = {}

-- Script properties are defined here
EndEarlyScript.Properties = {
	-- Example property
	{name = "gameController", type = "entity"},
}

--This function is called on the server when this entity is created
function EndEarlyScript:Init()
	self.requestsToEnd = 0
	self.timer = 0
end


function EndEarlyScript:OnButtonPressed(button)
	if #(GetWorld():GetUsers()) == 1 and button == "next" then
		self.timerStart = true
		self.requestsToEnd = self.requestsToEnd + 1
		if self.requestsToEnd < 3 then
			local timesLeft = 3 - self.requestsToEnd
			local text = "Press " .. button .. " " .. timesLeft .. " more times to end early."
			self:GetEntity():SendToScripts("Shout",text)
		end
	
		if self.requestsToEnd == 3 then
			self.properties.gameController.gameScript:EndPlay()	
			local text = "Request to end game early.. Resetting."
			self:GetEntity():SendToScripts("Shout",text)
			self.requestsToEnd = 0
			self.timerStart = false
			self.timer = 0
		end
	end
end

function EndEarlyScript:OnTick(dt)
	if self.timerStart then
		self.timer = self.timer + dt
	end
	
	if self.timer > 5 and self.requestsToEnd > 0 then
		self.requestsToEnd = 0
		self.timerStart = false
		self.timer = 0
	end
end

return EndEarlyScript
