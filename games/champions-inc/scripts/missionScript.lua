local MissionScript = {}

-- Script properties are defined here
MissionScript.Properties = {
	-- Example property
	{ name = "id", type = "string" },
	{ name = "name", type = "text" },
	{ name = "description", type = "text" },
	{ name = "difficulty", type = "number", min = 0, max = 1, tooltip = "Higher is more difficult. Zero would mean you can't fail, 1 would mean it's not possible to succeed (without the stats)" },
	{ name = "duration", type = "number", default = 15, tooltip = "Duration in minutes" },
	{ name = "rescueMission", type = "boolean" },
	{ name = "alignment", type = "string", options = { "good", "evil" }, default = "good" },
}

--This function is called on the server when this entity is created
function MissionScript:Init()
end

return MissionScript
