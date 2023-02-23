TimeOfDay = {}

TimeOfDay.Properties = {
	{ name = "useUTCTime", type = "boolean", },
	{ name = "startEvening", type = "number", editor = "days", default = 18 / 24, },
	{ name = "startMorning", type = "number", editor = "days", default = 6 / 24, },
	{ name = "dayCheckInterval", type = "number", editor = "seconds", default = 60, },
}

function TimeOfDay:Init()

	if self.properties.useUTCTime then
		Print("Setting to UTC time and 24 hour day")
		local secondsPerDay = 60 * 60 * 24
		GetWorld().startTime = (GetWorld():GetUTCTime() % secondsPerDay) / secondsPerDay
		GetWorld().dayLength = secondsPerDay
	end

	local lastIsDay = self:IsDayTime()
	self:Schedule(
		function()
			Wait(1.0)
			while true do
				Wait(self.properties.dayCheckInterval)
				local isDay = self:IsDayTime()
				if isDay and not lastIsDay then
					Print("TimeOfDay: Day")
					self:SendEventToListeners("OnDayTime", true)
				elseif not isDay and lastIsDay then
					Print("TimeOfDay: Night")
					self:SendEventToListeners("OnDayTime", false)
				end
				lastIsDay = isDay
			end
		end
	)

end

function TimeOfDay:IsDayTime()
	local timeOfDay = GetWorld():GetTimeOfDay()
	return ((timeOfDay > self.properties.startMorning) and (timeOfDay < self.properties.startEvening))
end

return TimeOfDay
