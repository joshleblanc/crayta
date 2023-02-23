local UserGameStateScript = {}

-- Script properties are defined here
UserGameStateScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "isInGame", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function UserGameStateScript:Init()
end

function UserGameStateScript:GameStart()
	self.properties.isInGame = true 
end

function UserGameStateScript:Eliminated()
	self.properties.isInGame = false
end

return UserGameStateScript
