local CommonCourtesyScript = {}

-- Script properties are defined here
CommonCourtesyScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function CommonCourtesyScript:Init()
end

function CommonCourtesyScript:OnChatMessage(user, msg)
	print(msg)
	print("on the user")
end

return CommonCourtesyScript
