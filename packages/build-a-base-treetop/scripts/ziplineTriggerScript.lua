local ZiplineTriggerScript = {}

-- Script properties are defined here
ZiplineTriggerScript.Properties = {
	-- Example property
	{ name = "position", type = "string", options = { "start", "end" }, default = "start"},
}

function ZiplineTriggerScript:GetInteractPrompt(prompts)
	local root = self:GetEntity():GetParent():GetParent()
	if root:FindScriptProperty("canGoBackwards") and self.properties.position == "end" then
		prompts.interact = root:FindScriptProperty("interactPrompt")
	end

	if self.properties.position == "start" then
		prompts.interact = root:FindScriptProperty("interactPrompt")
	end
end

return ZiplineTriggerScript
