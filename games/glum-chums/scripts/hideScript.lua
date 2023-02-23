local HideScript = {}

-- Script properties are defined here
HideScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function HideScript:Init()
	self:GetEntity().visible = false
end

return HideScript
