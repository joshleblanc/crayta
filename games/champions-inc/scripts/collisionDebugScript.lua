local CollisionDebugScript = {}

-- Script properties are defined here
CollisionDebugScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function CollisionDebugScript:Init()
end

function CollisionDebugScript:OnCollision(entity)
	--print("Collision Debug Script", entity:GetName())

end

return CollisionDebugScript
