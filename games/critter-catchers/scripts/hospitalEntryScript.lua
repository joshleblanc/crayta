local HospitalEntryScript = {}

-- Script properties are defined here
HospitalEntryScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" },
	{ name = "spawnLocation", type = "entity" },
}

--This function is called on the server when this entity is created
function HospitalEntryScript:Init()
end

return HospitalEntryScript
