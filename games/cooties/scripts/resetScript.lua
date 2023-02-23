local ResetScript = {}

-- Script properties are defined here
ResetScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onReset", type = "event" },
	{ name = "enabled", type = "boolean", default = false },
}

--This function is called on the server when this entity is created
function ResetScript:Init()
end

function ResetScript:OnButtonPressed(btn)
	if not self.properties.enabled then return end 
	
	if btn == "extra2" then 
		self.properties.onReset:Send()
	end
end

return ResetScript
