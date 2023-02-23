local LightSwitchScript = {}

-- Script properties are defined here
LightSwitchScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "lights", type = "entity", container = "array" },
	{ name = "sound", type = "soundasset" },
	{ name = "on", type = "boolean", default = true },
}

--This function is called on the server when this entity is created
function LightSwitchScript:Init()
	assert(#self.properties.lights > 0, "The Light Switch template must has at least one light assigned to the lights property")
	self.rot = self:GetEntity():GetRotation()
	
	if self.properties.on then 
		self:Rotate()
		self:SetLight(true)
	else
		self:SetLight(false)
	end
end

function LightSwitchScript:SetLight(state)
	for i=1,#self.properties.lights do 
		self.properties.lights[i].visible = state
	end
end

function LightSwitchScript:OnInteract()
	self.properties.on = not self.properties.on
	self:SetLight(self.properties.on)
	self:Rotate()
end

function LightSwitchScript:Rotate()
	self.rot.pitch = (self.rot.pitch + 180 % 360)
	self:GetEntity():SetRotation(self.rot)
end

return LightSwitchScript
