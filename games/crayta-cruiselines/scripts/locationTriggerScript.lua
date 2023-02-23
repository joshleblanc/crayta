local LocationTriggerScript = {}

-- Script properties are defined here
LocationTriggerScript.Properties = {
	-- Example property
	{ name = "name", type = "text" },
	{ name = "floor", type = "number", default = 1 }
}

function LocationTriggerScript:OnTriggerEnter(entity)
	entity:SendToScripts("SetLocation", self.properties.name)
end

function LocationTriggerScript:OnTriggerExit(entity)
	entity:SendToScripts("SetLocation", "")
end

return LocationTriggerScript
