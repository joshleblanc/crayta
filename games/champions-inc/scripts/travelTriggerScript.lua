local TravelTriggerScript = {}

-- Script properties are defined here
TravelTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "location", type = "template" },
	{ name = "spawn", type = "string" }
}

--This function is called on the server when this entity is created
function TravelTriggerScript:Init()
end

function TravelTriggerScript:OnTriggerEnter(player)
	player:GetUser():SendToScripts("GoTo", self.properties.location, self.properties.spawn)
end

return TravelTriggerScript
