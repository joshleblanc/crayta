local DoorStayOpenScript = {}

-- Script properties are defined here
DoorStayOpenScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function DoorStayOpenScript:Init()
	self:GetEntity():PlayAnimation("Open")
end

return DoorStayOpenScript
