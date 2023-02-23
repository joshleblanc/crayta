local UserColorCircleScript = {}

-- Script properties are defined here
UserColorCircleScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "color", type = "string", options = { "blue", "yellow", "green", "red" }, editable = false }
}

--This function is called on the server when this entity is created

function UserColorCircleScript:SetColor(color)
	self.properties.color = color
end

return UserColorCircleScript
