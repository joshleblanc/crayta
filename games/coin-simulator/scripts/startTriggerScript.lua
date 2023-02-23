local StartTriggerScript = {}

-- Script properties are defined here
StartTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function StartTriggerScript:Init()
end

function StartTriggerScript:OnTriggerEnter(player)
	player:GetUser():SendToScripts("ClientSay", "go")
	player:GetUser().userGameScript:Start()
end

return StartTriggerScript
