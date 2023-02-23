local ActiveOnStart = {}

-- Script properties are defined here
ActiveOnStart.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ActiveOnStart:Init()
	self:GetEntity():PlayAnimation("Open")
end

return ActiveOnStart
