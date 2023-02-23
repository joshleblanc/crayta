local TeleportScript = {}

-- Script properties are defined here
TeleportScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "target", type = "entity" }
}

--This function is called on the server when this entity is created
function TeleportScript:Init()
end

function TeleportScript:OnInteract(player)
	player:SetPosition(self.properties.target:GetPosition())
	player:SetRotation(self.properties.target:GetRotation())
end

function TeleportScript:GetInteractPrompt(prompts)
	prompts.interact = "Teleport to ground"
end

return TeleportScript
