local DamageRedirectScript = {}

-- Script properties are defined here
DamageRedirectScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function DamageRedirectScript:Init()
end

function DamageRedirectScript:OnDamage(...)
	self:GetEntity():GetParent():SendToScripts("OnDamage", ...)
end

return DamageRedirectScript
