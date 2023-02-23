local FloorTriggerScript = {}

-- Script properties are defined here
FloorTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "floor", type = "number", default = 1 }
}

--This function is called on the server when this entity is created
function FloorTriggerScript:Init()
end

function FloorTriggerScript:OnTriggerEnter(player)
	player:SendToScripts("SetFloor", self.properties.floor)
end

return FloorTriggerScript
