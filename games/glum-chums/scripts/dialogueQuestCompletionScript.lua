local DialogueQuestCompletionScript = {}

-- Script properties are defined here
DialogueQuestCompletionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onComplete", type = "event" },
	{ name = "dialogueQuest", type = "string" },
}

--This function is called on the server when this entity is created
function DialogueQuestCompletionScript:Init()
end

function DialogueQuestCompletionScript:HandleDialogueEvent(user)
	if user ~= self:GetEntity() then return end
	
	self.properties.onComplete:Send()
end

return DialogueQuestCompletionScript
