local MonsterStorageScript = {}

-- Script properties are defined here
MonsterStorageScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function MonsterStorageScript:Init()
end

function MonsterStorageScript:OnTriggerEnter(player)
	player:SendToScripts("ShowStorage")
end

return MonsterStorageScript
