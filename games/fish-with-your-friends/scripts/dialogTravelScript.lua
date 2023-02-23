local DialogTravelScript = {}

-- Script properties are defined here
DialogTravelScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "location", type = "template" },
	{ name = "spawn", type = "string" },
	{ name = "sound", type = "soundasset" },
}

--This function is called on the server when this entity is created
function DialogTravelScript:Init()
end

function DialogTravelScript:Travel(user)
	user.userLocationScript:GoTo(self.properties.location, self.properties.spawn, self.properties.sound)
end

return DialogTravelScript
