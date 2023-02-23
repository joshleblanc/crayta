local UserHudScript = {}

-- Script properties are defined here
UserHudScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "eventsController", type = "entity" },
}

--This function is called on the server when this entity is created
function UserHudScript:Init()
	self:UpdateDecoCounts()
end

function UserHudScript:LocalInit()
	self.entity = self:GetEntity()
	self.widget = self.entity.userHudWidget
	self.widget.js.data.tickets = self.entity.userMoneyScript:GetMoneyAmount()
	self.world = GetWorld()
end

function UserHudScript:HandleDecorationUnlock()
	self:UpdateDecoCounts()
end

function UserHudScript:UpdateDecoCounts()
	local user = self:GetEntity()
	local room = user.userRoomScript.properties.room
	
	self:Schedule(function()
		while not room do 
			Wait()
			room = user.userRoomScript.properties.room
		end
		local total = 0
		local owns = 0
		
		room.roomScript:ForEachDecoration(function(deco)
			if room.roomScript:Owns(user, deco:FindScriptProperty("id")) then
				owns = owns + 1
			else 
				print("Doesn't own", deco:FindScriptProperty("name"))
			end
			total = total + 1
		end)
		
		self:SendToLocal("UpdateWidget", owns, total)
	end)
end

function UserHudScript:UpdateWidget(owns, total)
	self.widget.js.data.decoUnlocked = owns
	self.widget.js.data.totalDeco = total
end

function UserHudScript:Enable()
	print("Enabling hud")
	if IsServer() then 
		self:SendToLocal("Enable")
		return
	end
	
	self.widget:Show()
end

function UserHudScript:Disable()
	print("Disabling hud")
	if IsServer() then 
		self:SendToLocal("Disable")
		return
	end
	
	self.widget:Hide()
end

function UserHudScript:LocalOnTick()
	local time = self.world:GetTimeOfDay()
	local totalMinutes = time * 24 * 60
	local hours = math.floor(totalMinutes / 60)
	local minutes = totalMinutes - (hours * 60)
	
	self.widget.js.data.time = string.format("%02d:%02d", hours, minutes) 
	
	self.widget.js.data.activeEvents = self:GetActiveEvents(totalMinutes)
	self.widget.js.data.upcomingEvents = self:GetUpcomingEvents()
end

function UserHudScript:GetActiveEvents(currentMinutes)
	local events = {}

	for _, event in ipairs(self.properties.eventsController.eventsControllerScript.events) do
		if event.properties.running then
			local timeLeft = event:MinutesLeft()
			local hours = math.floor(timeLeft / 60)
			local minutes = timeLeft - (hours * 60)
			
			table.insert(events, {
				name = event.properties.name,
				timeLeft = string.format("%02d:%02d", hours, minutes)
			})
		end
	end
	return events
end

function UserHudScript:GetUpcomingEvents()
	local events = {}
	for _, event in ipairs(self.properties.eventsController.eventsControllerScript.events) do
		
		if event:IsUpcoming() then
			local totalMinutes = event:GetEventMinutes()
			local hours = math.floor(totalMinutes / 60)
			local minutes = totalMinutes - (hours * 60)
		
			local totalMinutesUntil = event:MinutesUntil()
			local hoursUntil = math.floor(totalMinutesUntil / 60)
			local minutesUntil = totalMinutesUntil - (hoursUntil * 60)
			
			if #events == 0 or (#events > 0 and totalMinutesUntil < events[1].totalMinutesUntil) then
				events = {{
					totalMinutesUntil = totalMinutesUntil,
					startsAt = string.format("%02d:%02d", hours, minutes),
					timeUntil = string.format("%02d:%02d", hoursUntil, minutesUntil),
					name = event.properties.name
				}}			
			end
		end
	end
	
	return events
end

function UserHudScript:HandleMoneyChange(amt, msg, total)
	if IsServer() then
		self:SendToLocal("HandleMoneyChange", amt, msg, total)
		return
	end
	
	print(amt, msg, total)
	
	self.widget.js.data.tickets = total
end

return UserHudScript
