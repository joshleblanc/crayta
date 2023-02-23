local BoothScript = {}

-- Script properties are defined here
BoothScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function BoothScript:Init()
end

function BoothScript:GetInteractPrompt(prompts)
	prompts.interact = "Play"
end

return BoothScript
