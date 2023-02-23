local SpawnDoorScript = {}

-- Script properties are defined here
SpawnDoorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function SpawnDoorScript:Init()
end

function SpawnDoorScript:OnTriggerEnter(player) 
	player:GetUser().playerStateScript:SendToScript("Play")
end

return SpawnDoorScript
