local EventScript = {}


-- Script properties are defined here
EventScript.Properties = {
	-- Example property
	{ name = "name", type = "string", tooltip = "Just for debugging" },
	{ name = "announcement", type = "text"},
	{ name = "endAnnouncement", type = "text" },
	{ name = "hour", type = "number", default = 12, min = 0, max = 23 },
	{ name = "minute", type = "number", default = 0, min = 0, max = 59 },
	{ name = "onRun", type = "event" },
	{ name = "onEnd", type = "event" },
	{ name = "onUpcoming", type = "event" },
	{ name = "endHour", type = "number", default = 12, min = 0, max = 23 },
	{ name = "endMinute", type = "number", default = 0, min = 0, max = 59 },
	{ name = "runToday", type = "boolean", default = false, editable = false },
	{ name = "canEnd", type = "boolean", default = false, editable = false },
	{ name = "endedToday", type = "boolean", default = false, editable = false },
	{ name = "running", type = "boolean", default = false, editable = false },
	{ name = "locator", type = "entity" },
	{ name = "floor", type = "number" }
 }

function EventScript:Init()
	self:IsoInit()

	self.lastTime = self.world:GetTimeOfDay()
end

function EventScript:ClientInit()
	self:IsoInit()
end

function EventScript:IsoInit()
	self.world = GetWorld()
end

function EventScript:GetEventMinutes()
	return (self.properties.hour * 60) + self.properties.minute
end

function EventScript:RewardParticipation(player)
	if self:Rewarded(player) then
		player:GetUser():SendToScripts("Shout", "You already got a coin today - come back tomorrow!")
	else
		table.insert(self.rewardedPlayers, player)
		player:GetUser():SendToScripts("AddMoney", 1, "You got a coin!")
		player:GetUser():AddToLeaderboardValue("events-participated", 1)
		player:GetUser():AddToLeaderboardValue("events-participated-weekly", 1)
		player:GetUser():SendXPEvent("event", { name = self.properties.name })
	end
end

function EventScript:Rewarded(player)
	for _, p in ipairs(self.rewardedPlayers) do
		if player == p then
			return true
		end
	end
	
	return false
end

function EventScript:Run()
	self.properties.running = true
	self.rewardedPlayers = {}
	self.upcoming = false
	self.properties.onRun:Send(self)
end

function EventScript:Stop()
	self.properties.running = false
	self.upcoming = false
	self.rewardedPlayers = {}
	self.properties.onEnd:Send(self)
end

function EventScript:GetEventEndMinutes()
	return (self.properties.endHour * 60) + self.properties.endMinute
end

function EventScript:IsUpcoming()
	return self:MinutesUntil() > 0
end

function EventScript:IsActive()
	return self.properties.running
end

function EventScript:OnTick()
	if self:IsUpcoming() and not self.upcoming then
		self.upcoming = true
		self.properties.onUpcoming:Send(self)
	end
end

function EventScript:MinutesLeft()
	if self.properties.runToday and not self.properties.endedToday or self.properties.canEnd then
		
		local currentTime = self.world:GetTimeOfDay() * 60 * 24
		local diff = self:GetEventEndMinutes() - currentTime

		if diff < 0 then
			return (24 * 60) - currentTime + self:GetEventEndMinutes()
		else
			return diff
		end
	else
		return 0
	end
end

function EventScript:Duration()
	return self:GetEventEndMinutes() - self:GetEventMinutes()
end

function EventScript:MinutesUntil()
	local timeUntil = self:GetEventMinutes() - (self.world:GetTimeOfDay() * 60 * 24)
	if timeUntil > 0 then
		return timeUntil
	else
		return 24 * 60 + timeUntil
	end
end

return EventScript
