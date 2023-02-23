local NpcTestScript = {}

-- Script properties are defined here
NpcTestScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function NpcTestScript:Init()
	print("bartender location", self:GetEntity():GetPosition(), self:GetEntity().visible)
end

function NpcTestScript:ClientInit()
	print("bartender location", self:GetEntity():GetPosition(), self:GetEntity().visible)
end

return NpcTestScript
