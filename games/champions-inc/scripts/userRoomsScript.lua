local UserRoomsScript = {}

-- Script properties are defined here
UserRoomsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserRoomsScript:Init()
	self.db = self:GetEntity().documentStoresScript.rooms
	print("db", self:GetEntity().documentStoresScript)
end

function UserRoomsScript:GetRoom(id)
	return self.db:FindOne({ _id = id })
end

function UserRoomsScript:BuyRoom(room)
	return self.db:InsertOne({ 
		_id = room.properties.id,
		templateName = room.properties.defaultTemplate:GetName()
	})
end

return UserRoomsScript
