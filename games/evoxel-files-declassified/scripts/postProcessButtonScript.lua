local PostProcessButtonScript = {}

-- Script properties are defined here
PostProcessButtonScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "postProcess", type = "postprocessasset" },
	{ name = "defaultPostProcess", type = "postprocessasset" },
	{ name = "prompt", type = "string" }
}


function PostProcessButtonScript:OnInteract(player)
	player:GetUser():SendToScripts("SetPostProcess", self.properties.postProcess)
end

function PostProcessButtonScript:GetInteractPrompt(prompts)
	prompts.interact = "Activate"
end

return PostProcessButtonScript
