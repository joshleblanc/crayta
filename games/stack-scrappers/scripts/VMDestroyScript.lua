local VMDestroyScript = {}

-- Script properties are defined here
VMDestroyScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function VMDestroyScript:Init()
end

function VMDestroyScript:Destroy()
	self:GetEntity():Destroy()
end

return VMDestroyScript
