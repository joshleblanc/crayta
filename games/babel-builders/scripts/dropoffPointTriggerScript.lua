local DropoffPointTriggerScript = {}

-- Script properties are defined here
DropoffPointTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function DropoffPointTriggerScript:GetInteractPrompt(prompts)
	prompts.interact = "Dropoff"
end

return DropoffPointTriggerScript
