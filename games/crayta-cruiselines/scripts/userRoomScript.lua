local UserRoomScript = {}

-- Script properties are defined here
UserRoomScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "rooms", type = "entity", container = "array" },
	{ name = "room", type = "entity", editable = false },
}

--This function is called on the server when this entity is created
function UserRoomScript:Init()
	self:Checkin()
end

function UserRoomScript:Checkin()
	for i=1,#self.properties.rooms do
		local room = self.properties.rooms[i]
		if not room.roomScript:HasOwner() then
			print("Set room")
			room:SendToScripts("Checkin", self:GetEntity())
			self.properties.room = room
			return
		end
	end
end

function UserRoomScript:HandleDecorationUnlock(id)
	print("handling decoration unlock", self.properties.room)
	if self.properties.room then
		self.properties.room:SendToScripts("ShowUnlock", id)
	end
end

return UserRoomScript
