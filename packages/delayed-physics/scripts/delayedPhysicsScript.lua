local DelayedPhysicsScript = {}

-- Script properties are defined here
DelayedPhysicsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function DelayedPhysicsScript:Init()
	self.pos = self:GetEntity():GetPosition()
	self.rot = self:GetEntity():GetRotation()
	
	self:GetEntity().damageEnabled = true
end

function DelayedPhysicsScript:OnDamage()
	self:GetEntity().physicsEnabled = true 
	self:GetEntity().damageEnabled = false
end

function DelayedPhysicsScript:Reset()
	self:GetEntity().physicsEnabled = false
	self:GetEntity().damageEnabled = true
	self:GetEntity():SetPosition(self.pos)
	self:GetEntity():SetRotation(self.rot)
end

return DelayedPhysicsScript
