local TeacherNodeScript = {}

-- Script properties are defined here
TeacherNodeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "nextNode", type = "entity" },
	{ name = "thingToLookAt", type = "entity" },
	
}

--This function is called on the server when this entity is created
function TeacherNodeScript:Init()
end

return TeacherNodeScript
