local LocationRespawnTriggerScript = {}

-- Script properties are defined here
LocationRespawnTriggerScript.Properties = {
}

function LocationRespawnTriggerScript:OnTriggerEnter(player)
	player:GetUser().userLocationScript:Respawn()
end

return LocationRespawnTriggerScript
