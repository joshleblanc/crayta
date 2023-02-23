local RedirectDamageScript = {}

-- Script properties are defined here
RedirectDamageScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "to", type = "entity" }
}

--This function is called on the server when this entity is created
function RedirectDamageScript:Init()
end

function RedirectDamageScript:OnDamage(...)
	self.properties.to:SendToScripts("OnDamage", ...)
end

return RedirectDamageScript
