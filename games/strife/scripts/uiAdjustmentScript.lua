local UiAdjustmentScript = {}

-- Script properties are defined here
UiAdjustmentScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "showCompass", type = "boolean", default = true },
	{ name = "showPayloadProgress", type = "boolean", default = true }
}

--This function is called on the server when this entity is created
function UiAdjustmentScript:LocalInit()
	local user = self:GetEntity():GetUser()
	
	if self.properties.showCompass then 
		user.userCompassScript:Show()
	else
		user.userCompassScript:Hide()
	end
	
	if self.properties.showPayloadProgress then 
		user.payloadProgressScript:Show()
	else 
		user.payloadProgressScript:Hide()
	end
end

return UiAdjustmentScript
