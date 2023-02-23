local TrapEffectScript = {}

-- Script properties are defined here
TrapEffectScript.Properties = {
	-- Example property
	{ name = "root", type = "entity" }
}

--This function is called on the server when this entity is created
function TrapEffectScript:Init()
	self:GetEntity().active = false
	
	self.properties.root.trapScript.properties.onActivate:Listen(self, "Play")
	self.properties.root.trapScript.properties.onDeactivate:Listen(self, "Stop")
end

function TrapEffectScript:Play()
	self:GetEntity().active = true
end

function TrapEffectScript:Stop()
	self:GetEntity().active = false
end

return TrapEffectScript
