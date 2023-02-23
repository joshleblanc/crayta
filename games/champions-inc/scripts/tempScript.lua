local TempScript = {}

-- Script properties are defined here
TempScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function TempScript:Init()
end

function TempScript:OnCollision(thing)
	print(thing:GetName())
end

return TempScript
