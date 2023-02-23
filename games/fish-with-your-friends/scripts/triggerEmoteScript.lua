local TriggerEmoteScript = {}

-- Script properties are defined here
TriggerEmoteScript.Properties = {
	-- Example property
	{name = "emoteChoices", type = "emoteasset", container = "array"},
}

--This function is called on the server when this entity is created
function TriggerEmoteScript:Init()
end

function TriggerEmoteScript:PerformEmoteOne(choice)
	self:GetEntity():PlayEmote(self.properties.emoteChoiceOne)
end



return TriggerEmoteScript
