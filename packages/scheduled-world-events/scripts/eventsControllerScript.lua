local EventsControllerScript = {}

-- Script properties are defined here
EventsControllerScript.Properties = {
	-- Example property
	{name = "annnouncementSound", type = "soundasset"},
	{ name = "startingSoonAnnouncement", type = "text" },
	{ name = "onEvent", type = "event" }
}

--This function is called on the server when this entity is created
function EventsControllerScript:Init()
	self.firstRun = true
	self.startTime = GetWorld():GetTimeOfDay() * 24 * 60
	self.events = self:GetEntity():FindAllScripts("eventScript")
end

function EventsControllerScript:ClientInit()
	self.events = self:GetEntity():FindAllScripts("eventScript")
end

function EventsControllerScript:OnTick()
	local time = GetWorld():GetTimeOfDay()
	local totalMinutes = time * 24 * 60
	
	for _, event in ipairs(self.events) do
		if time < event.lastTime then
			event.upcomingAnnounced = false
			event.properties.runToday = false
			event.properties.canEnd = true
		end
		event.lastTime = time	
		
		local eventTime = event:GetEventMinutes()
		
		-- On the first run, skip anything that started prior to the server starting
		if eventTime >= self.startTime or not self.firstRun then
			if not event.properties.runToday and totalMinutes >= eventTime then
				print("Running", event.properties.name, self.firstRun, time, self.startTime)
				event.properties.runToday = true	
				event.properties.canEnd = eventTime < event:GetEventEndMinutes()
				event.properties.endedToday = false
				self:StartEvent(event)
				self.properties.onEvent:Send()
			end
		end
		
		if event.properties.running and event.properties.canEnd and totalMinutes >= event:GetEventEndMinutes() then
			event.properties.canEnd = false
			event.properties.endedToday = true
			self:EndEvent(event)
			self.properties.onEvent:Send()
		end
		
		if event:IsUpcoming() and not event.upcomingAnnounced then
			event.upcomingAnnounced = true
			self:Announce(Text.Format(self.properties.startingSoonAnnouncement, event.properties.name))
			self.properties.onEvent:Send()
		end
	end
	
	-- if the current time is less than the start time, then we've left the first day
	-- and can flip that switch off
	if totalMinutes < self.startTime and self.firstRun then
		self.firstRun = false
	end
end

function EventsControllerScript:Announce(announcement)
	if announcement and string.len(tostring(announcement)) > 0 then 
		self:GetEntity():PlaySound2D(self.properties.annnouncementSound)
		GetWorld():ForEachUser(function(userEntity)
			userEntity:SendToScripts("Shout", announcement)
		end)
	end
end

function EventsControllerScript:EndEvent(event)
	self:Announce(event.properties.endAnnouncement)
	event:Stop()
end

function EventsControllerScript:StartEvent(event)
	self:Announce(event.properties.announcement)
	event:Run()
end

return EventsControllerScript
