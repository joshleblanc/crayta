local FallDamageOverridesScript = {}

-- Script properties are defined here
FallDamageOverridesScript.Properties = {
	-- Example property
	{ name = "damageMultiplier", type = "number", default = 1 }
}

function FallDamageOverridesScript:Reset()
	self.properties.damageMultiplier = 1
end

return FallDamageOverridesScript
