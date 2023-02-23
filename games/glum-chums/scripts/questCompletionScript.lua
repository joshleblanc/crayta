local QuestCompletionScript = {}

-- Script properties are defined here
QuestCompletionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onComplete", type = "event" },
}

--This function is called on the server when this entity is created
function QuestCompletionScript:Init()
end

function QuestCompletionScript:HandleComplete(user)
	if user ~= self:GetEntity() then return end
	
	self.properties.onComplete:Send()
end

return QuestCompletionScript
