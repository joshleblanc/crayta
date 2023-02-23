local LightScriptForDarkness = {}

-- Script properties are defined here
LightScriptForDarkness.Properties = {
	-- Example property
	{name = "maxBrightness", type = "number", default =100,},
	{name = "speedOfLight", type = "number", default =.2,},
	{name = "lightBulb", type = "entity"},
}

--This function is called on the server when this entity is created
function LightScriptForDarkness:Init()
	self.turnLightOn = false
	self.turnLightOff = false
end

function LightScriptForDarkness:HighNoonNotActive()
	self.turnLightOn = true
	self.properties.lightBulb.intensity = 1
end

function LightScriptForDarkness:HighNoonActive()
	self.turnLightOff = true
end


function LightScriptForDarkness:OnTick(dt)
	if self.turnLightOn == true and self.properties.lightBulb.intensity < self.properties.maxBrightness then
		self.properties.lightBulb.intensity = self.properties.lightBulb.intensity + (self.properties.lightBulb.intensity * self.properties.speedOfLight)
		print("Turning light up")
	else
		self.turnLightOn = false
	end
	
	if self.turnLightOff == true and self.properties.lightBulb.intensity > 0 then
		self.properties.lightBulb.intensity = self.properties.lightBulb.intensity - (self.properties.lightBulb.intensity * self.properties.speedOfLight)
		print("Turning light down")
	else
		self.turnLightOff = false
	end
end

return LightScriptForDarkness
