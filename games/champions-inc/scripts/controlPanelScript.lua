local ControlPanelScript = {}

-- Script properties are defined here
ControlPanelScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ControlPanelScript:Init()
end

function ControlPanelScript:OnInteract(player)
	player:GetUser().userControlPanelScript:Show()
end

return ControlPanelScript
