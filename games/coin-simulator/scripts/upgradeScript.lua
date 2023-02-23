local UpgradeScript = {}

-- Script properties are defined here
UpgradeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UpgradeScript:Init()
end

function UpgradeScript:OnInteract(player)
	player:GetUser().userUpgradeScript:Show()
end

function UpgradeScript:GetInteractPrompt(prompts)
	prompts.interact = "Upgrade"
end

return UpgradeScript
