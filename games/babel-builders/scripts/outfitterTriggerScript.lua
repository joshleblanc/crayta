local OutfitterTriggerScript = {}

-- Script properties are defined here
OutfitterTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "prompt", type = "text" }
}

--This function is called on the server when this entity is created
function OutfitterTriggerScript:Init()
end

function OutfitterTriggerScript:GetInteractPrompt(prompts)
	prompts.interact = self.properties.prompt
end

return OutfitterTriggerScript
