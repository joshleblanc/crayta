local Timer = {}

-- Script properties are defined here
Timer.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function Timer:LocalInit()
	self.widget = self:GetEntity():FindWidget("timerWidget")
	self.widget:Hide()
	self:SetTime(0)
	
	self.running = false
end

function Timer:Init()
	self.lastDuration = 0
end

function Timer:LocalOnTick(dt)
	if self.running then
		self:SetTime(self.duration + dt)
	end
	
end

function Timer:ProcessActivities(duration)
	local diff = duration - self.lastDuration
	if diff > 5 then
		self:GetEntity():GetUser():SendXPEvent("survive")
		self.lastDuration = duration
	end
	
end

function Timer:AddScore(score)
	--self:SetTime(self.duration + score)

end

function Timer:SetTime(time)
	if not self:GetEntity():IsLocal() then
		self:GetEntity():SendToLocal("SetTime", time)
		return
	end
	
	self.duration = time
	self.widget.js.timer.time = Text.FormatTime("{mm}:{ss}", time)
	
	self:SendToServer("ProcessActivities", self.duration)
	--self.widget.js.timer.time = time
end

function Timer:Start()
	if IsServer() then
		self.lastDuration = 0
		self:GetEntity():SendToLocal("Start")
		return
	end
	
	self.running = true
	self:SetTime(0)
	self.widget:Show()
end

function Timer:ProcessEvents(user, duration)
	if not IsServer() then
		self:GetEntity():SendToServer("ProcessEvents", user, duration)
		return
	end
	
	if not user then
		return
	end
	
	if duration >= 30 then
		user:SendChallengeEvent("30-seconds")
	end
	
	if duration >= 60 then
		user:SendChallengeEvent("60-seconds")
	end
	
	if duration >= 90 then
		user:SendChallengeEvent("90-seconds")
	end
	
	print("setting leaderboard", duration, user:GetUsername())
		
	user:SetLeaderboardValue("best-time-all-jump", duration)
	user:SetLeaderboardValue("best-time-week", duration)
end

function Timer:Hide(user)
	if IsServer() then
		self:GetEntity():SendToLocal("Hide", user)
		return
	end
	self.widget:Hide()
end

function Timer:Stop(user)
	if IsServer() then
		self:GetEntity():SendToLocal("Stop", user)
		return
	end
	
	if not self.running then return end 
	
	self.running = false
	self:ProcessEvents(user, self.duration)
end

return Timer
