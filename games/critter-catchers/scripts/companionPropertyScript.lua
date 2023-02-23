local CompanionPropertyScript = {}

-- Script properties are defined here
CompanionPropertyScript.Properties = {
	-- Example property
	{name = "cam", type = "entity"},
	{name = "enter", type = "event"},
	{name = "colorPieces", type = "entity", container = "array"},
	{name = "colorEffect", type = "entity"},
	
}

--This function is called on the server when this entity is created
function CompanionPropertyScript:Init()
end

function CompanionPropertyScript:Entered(thing)
	
end



return CompanionPropertyScript
