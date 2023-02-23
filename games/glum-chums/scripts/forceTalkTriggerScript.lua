local ForceTalkTriggerScript = {}

-- Script properties are defined here
ForceTalkTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "questId", type = "string" },
	{ name = "dialogControl", type = "entity" }
}

--This function is called on the server when this entity is created
function ForceTalkTriggerScript:Init()
end

function ForceTalkTriggerScript:OnTriggerEnter(player)
	local user = player:GetUser()
	local quest = user.userQuestsScript:FindQuest(self.properties.questId)
	
	if quest:IsComplete() then return end
	
	self.properties.dialogControl:SendToScripts("StartDialog", user)
end

return ForceTalkTriggerScript
