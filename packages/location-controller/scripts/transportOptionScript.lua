local TransportOptionScript = {}

-- Script properties are defined here
TransportOptionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "text" },
	{ name = "template", type = "template" },
	{ name = "spawnLocation", type = "string", tooltip = "One of the IDs of a spawn location in the template" }
}

--This function is called on the server when this entity is created
function TransportOptionScript:Init()
end

function TransportOptionScript:GetPosition()
	return self.properties.target:GetPosition()
end

return TransportOptionScript
