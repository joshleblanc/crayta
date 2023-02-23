local HealthOverride = {}

-- Script properties are defined here
HealthOverride.Properties = {
	-- Example property
	{ name = "maxHp", type = "number", default = 1000 }
}

function HealthOverride:Reset()
	self.properties.maxHp = 1000
end

return HealthOverride
