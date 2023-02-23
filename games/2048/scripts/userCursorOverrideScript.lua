local UserCursorOverrideScript = {}

-- Script properties are defined here
UserCursorOverrideScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserCursorOverrideScript:LocalInit()
	self.widget = self:GetEntity().userCursorOverrideWidget
end

function UserCursorOverrideScript:EnableCursor()
	self.widget:Show()
end
function UserCursorOverrideScript:DisableCursor()
	self.widget:Hide()
end

return UserCursorOverrideScript
