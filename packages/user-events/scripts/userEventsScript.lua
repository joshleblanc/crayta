local UserEventsScript = {}


local EVENTS = {
	"OnIronSightStart",
	"OnIronSightStop", "OnSprintStart",
	"OnSprintStop", "OnCrouch",
	"OnStand", "OnJump",
	"OnHotbarChanged", "OnChatMessage",
	"OnMantleStart", "OnMantleStop",
	"OnSlideStart", "OnSlideStop",
	"OnRollStart", "OnRollStop",
	"OnSpawnEffectEnded", "OnActivityTriggered"
}

-- Script properties are defined here
UserEventsScript.Properties = {
	{ name = "onButtonPressed", type = "event" },
	{ name = "onButtonReleased", type = "event" }
}

for _, event in ipairs(EVENTS) do 
	local eventName = "o" .. string.sub(event, 2, #event)
	
	table.insert(UserEventsScript.Properties, { name = eventName, type = "event" })
	
	UserEventsScript[event] = function(self, ...) 
		self.properties[eventName]:Send(...)
	end
	
	UserEventsScript["Local" .. event] = function(self, ...)
		self.properties[eventName]:Send(...)
	end
end

--[[
	LocalOnButtonPressed isn't fired when a cursor enabled widget is visible.
	To get around this, we have a perma-visible widget that reports LocalOnButtonPressed, which 
	we use instead of the script-side LocalOnButtonPressed.
	
	Since we need to override the LocalOnButtonPressed, we can't use the above function generation,
	so we do it manually.
]]--
function UserEventsScript:OnButtonPressed(btn)
	self.properties.onButtonPressed:Send(btn)
end

function UserEventsScript:WidgetOnButtonPressed(btn)
	self.properties.onButtonPressed:Send(btn)
end

function UserEventsScript:OnButtonReleased(btn)
	self.properties.onButtonReleased:Send(btn)
end

function UserEventsScript:WidgetOnButtonReleased(btn)
	self.properties.onButtonReleased:Send(btn)
end

return UserEventsScript
