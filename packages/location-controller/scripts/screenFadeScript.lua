local ScreenFadeScript = {}

ScreenFadeScript.Properties = {
	{name = "defaultColor", type = "color", default = Color.New(1, 1, 1)},
}

function ScreenFadeScript:LocalInit()
	self.widget = self:GetEntity().screenFadeWidget
	self.widget.js.data.opacity = 0
	self.widget:Hide()
end

function ScreenFadeScript:DoScreenFadeOut(fadeTime, color)
	if IsServer() then 
		self:SendToLocal("DoScreenFadeOut", fadeTime)
		return
	end
	
	color = color or self.properties.defaultColor
	holdTime = holdTime or 0
	local colorString = self:GetColorString(color)
	
	self.widget:Show()
	self.widget.js.data.opacity = 0
	self.widget.js.data.color = colorString
	
	self:Schedule(function()
		local t = 0
		local sinProg = 0
		while t < fadeTime do
			t = t + Wait()
			sinProg = math.sin((t / fadeTime) * (math.pi / 2))
			self.widget.js.data.opacity = sinProg
		end
	end)
end

function ScreenFadeScript:DoScreenFadeIn(fadeTime)
	if IsServer() then 
		self:SendToLocal("DoScreenFadeIn", fadeTime)
		return
	end
	
	self:Schedule(function()
		t = 0
		while t < fadeTime do
			t = t + Wait()
			sinProg = math.sin(((t / fadeTime) * (math.pi / 2)) + (math.pi / 2))
			self.widget.js.data.opacity = sinProg
		end
		self.widget.js.data.opacity = 0
		self.widget:Hide()
		self.fadeSchedule = nil
	end)

end

-- Plays a screen fade
-- Fade time is the time to fade in, and, separately, to fade out
-- So if 1 is passed, it will take 1 sec to fade in, 1 to fade out
-- Hold time is optional, and will stay on full opacity for this time (default is 0)
-- Color is an optional color value that can be passed, or it will use the default color property
function ScreenFadeScript:DoScreenFade(fadeTime, holdTime, color)
	if self:GetEntity():IsLocal() then
		if self.fadeSchedule then
			self:Cancel(self.fadeSchedule)
		end
		
		color = color or self.properties.defaultColor
		holdTime = holdTime or 0
		local colorString = self:GetColorString(color)
		
		self.widget:Show()
		self.widget.js.data.opacity = 0
		self.widget.js.data.color = colorString
		self.fadeSchedule = self:Schedule(
			function()
				local t = 0
				local sinProg = 0
				while t < fadeTime do
					t = t + Wait()
					sinProg = math.sin((t / fadeTime) * (math.pi / 2))
					self.widget.js.data.opacity = sinProg
				end
				Wait(holdTime)
				t = 0
				while t < fadeTime do
					t = t + Wait()
					sinProg = math.sin(((t / fadeTime) * (math.pi / 2)) + (math.pi / 2))
					self.widget.js.data.opacity = sinProg
				end
				self.widget.js.data.opacity = 0
				self.widget:Hide()
				self.fadeSchedule = nil
			end
		)
	else
		self:SendToLocal("DoScreenFade", fadeTime, holdTime, color)
	end
end

function ScreenFadeScript:GetColorString(color)
	local multiplier = 255
	if color.red > 1 or color.green > 1 or color.blue > 1 then multiplier = 1 end
	local colorString = "rgb("
	colorString = colorString .. tostring(math.floor(color.red * multiplier)) .. ", "
	colorString = colorString .. tostring(math.floor(color.green * multiplier)) .. ", "
	colorString = colorString .. tostring(math.floor(color.blue * multiplier))
	colorString = colorString .. ")"
	return colorString
end

return ScreenFadeScript
