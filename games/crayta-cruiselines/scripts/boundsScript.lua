local BoundsScript = {}

-- Script properties are defined here
BoundsScript.Properties = {
	-- Example property
	{ name = "floor", type = "number", min = 1, max = 5, default = 1 },
	{ name = "order", type = "number", default = 1 }
}

--This function is called on the server when this entity is created
function BoundsScript:Init()
end

return BoundsScript
