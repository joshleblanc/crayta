local RoomDecorationScript = {}

-- Script properties are defined here
RoomDecorationScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" }
}

--This function is called on the server when this entity is created
function RoomDecorationScript:Init()
	
end

function RoomDecorationScript:HandleUnlock()

end

return RoomDecorationScript
