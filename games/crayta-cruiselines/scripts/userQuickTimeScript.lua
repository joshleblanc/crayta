local UserQuickTimeScript = {}

-- Script properties are defined here
UserQuickTimeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onQuickTimeEventStart", type = "event" },
	{ name = "onQuickTimeEventEnd", type = "event" },
	{ name = "missVibration", type = "vibrationeffectasset" }
}

-- doesn't have "forward", "backward", "left", "right" , "crouch", "jump", "sprint"
local buttons = {
	"interact", 
	"primary", "secondary", "previous",
	"extra1", "extra2", "extra3", "extra4", "extra5"
}

function UserQuickTimeScript:LocalInit()
	self.entity = self:GetEntity()
	self.world = GetWorld()
	self.widget = self.entity.userQuickTimeWidget
	self.widget:Hide()
end

function UserQuickTimeScript:InternalRandomButtonPressQTE(timeLimit, opts, cb)
	local btn = self:GetRandomButton()
	print("InternalRandomButtonPressQTE", btn, timeLimit, opts, cb)
	self:InternalButtonPressQTE(btn, timeLimit, opts, cb)
end

function UserQuickTimeScript:GetRandomButton()
	return buttons[math.random(1, #buttons)]
end

function UserQuickTimeScript:RandomButtonPressQTE(timeLimit, opts) 
	if opts == nil then
		opts = {}
	end
	print("InternalRandomButtonPressQTE", timeLimit, opts)
	return self:WaitForButtonPress("InternalRandomButtonPressQTE", timeLimit, opts)
end

function UserQuickTimeScript:ButtonPressQTE(btn, timeLimit, opts)
	if opts == nil then
		opts = {}
	end
	return self:WaitForButtonPress("InternalButtonPressQTE", btn, timeLimit, opts)
end

function UserQuickTimeScript:WaitForButtonPress(method, ...)
	local done = false
	local result
	
	local args = { ... }
	table.insert(args, function(r)
		print("Got Result")
		done = true
		result = r
	end)
	
	print(args)
	self[method](self, unpack(args))
	
	while not done do
		Wait()
	end
	
	return result
end

function UserQuickTimeScript:InternalButtonPressQTE(btn, timeLimit, opts, cb)
	if self:IsServer() then return end 
	
	self.callback = cb
	self.btn = btn
	self.opts = opts
	print("options", btn, timeLimit, opts, cb)
	self.timeLimit = timeLimit
	self.timeTaken = 0
	
	self.scheduleHandle = self:Schedule(function()
		Wait(timeLimit)
		
		if self.callback then
			self.widget.js.data.show = false
			self.callback(false)
			self.callback = nil
		end
	end)
	
	self.widget:CallFunction("ButtonPressQTE", Text.Format("{{1}-icon-raw}", btn), timeLimit)
end

function UserQuickTimeScript:LocalOnTick(dt)
	if self.callback then
		self.timeTaken = self.timeTaken + dt
	end
end

function UserQuickTimeScript:ButtonPressResponse()
	if self.callback then
		self.callback(true)
	end
end

function UserQuickTimeScript:LocalOnButtonPressed(btn)
	if not self.callback then return end 
	print(self.opts)
	if btn == self.btn then
		local threshold = self.timeLimit * 0.25
		local diff = self.timeLimit - self.timeTaken
		
		local up = self.timeLimit * 0.12
		local down = self.timeLimit * 0.04
		
		if diff < up then
			if not self.opts.skipAnnouncement then
				self.widget:CallFunction("Hit")
			end
		
			print("Hit")
			self.callback(true)
		else
			print("Hissed")
			self.entity:PlayVibrationEffect(self.properties.missVibration)
			if not self.opts.skipAnnouncement then
				self.widget:CallFunction("Miss")
			end
			
			self.callback(false)
		end	
	else
		print("Missed, timeout")
		self.entity:PlayVibrationEffect(self.properties.missVibration)
		if not self.opts.skipAnnouncement then
			self.widget:CallFunction("Miss")
		end
		self.callback(false)
	end
	
	self.widget.js.data.show = false
	
	if self.scheduleHandle then
		self:Cancel(self.scheduleHandle)
	end
end

function UserQuickTimeScript:DoQuickTimeEvent(fn)
	self.widget:Show()
	self:GetEntity():GetPlayer():SetInputLocked(true)
	print("Sending quick time start event")
	self.properties.onQuickTimeEventStart:Send()
	self:Schedule(function()
		fn()
		self:EndQuickTimeEvent()
	end)
end

function UserQuickTimeScript:EndQuickTimeEvent()
	self.callback = false
	self.widget:Hide()
	self:GetEntity():GetPlayer():SetInputLocked(false)
	self.properties.onQuickTimeEventEnd:Send()
end

function UserQuickTimeScript:IsServer()
	if IsServer() then 
		print("Quick time events cannot be run on the server")
		return true
	end
	
	return false
end

return UserQuickTimeScript
