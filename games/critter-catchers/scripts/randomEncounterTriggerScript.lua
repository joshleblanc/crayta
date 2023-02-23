local RandomEncounterTriggerScript = {}

-- Script properties are defined here
RandomEncounterTriggerScript.Properties = {
	{ name = "levelMin", type = "number", default = 1 },
	{ name = "levelMax", type = "number", default = 1 },
}

--This function is called on the server when this entity is created
function RandomEncounterTriggerScript:Init()
end

function RandomEncounterTriggerScript:OnTriggerEnter(player)
	player.playerEncounterScript:EnableEncounters(self:GetEntity().lootTableScript, self.properties.levelMin, self.properties.levelMax)
end

function RandomEncounterTriggerScript:OnTriggerExit(player)
	player.playerEncounterScript:DisableEncounters()
end

return RandomEncounterTriggerScript
