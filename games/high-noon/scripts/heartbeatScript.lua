local HeartbeatScript = {}

-- Script properties are defined here
HeartbeatScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "sound", type = "entity" }
}

--This function is called on the server when this entity is created
function HeartbeatScript:OnTick()
	if self:GetEntity().visible then
		self.properties.sound.active = true	
	else
		self.properties.sound.active = false
	end
end

return HeartbeatScript
