local RoomDoorScript = {}

-- Script properties are defined here
RoomDoorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" },
	{ name = "interactSound", type = "soundasset" },
	{ name = "to", type = "template" },
}

--This function is called on the server when this entity is created
function RoomDoorScript:Init()
	self.spawned = false
	self:FindRoom()
end

function RoomDoorScript:HandlePlayerEnter(p)
	p:PlaySound(self.properties.interactSound)
	local user = p:GetUser()
	user.userRunScript:SpawnRoom(self)
end

function RoomDoorScript:GetInteractPrompt(prompts)
	prompts.interact = "Travel"
end

function RoomDoorScript:FindRoom()
	if self.room then 
		return self.room
	else
		local p = self:GetEntity()
		while p and not p.roomScript do 
			p = p:GetParent()
		end
		self.room = p
		return self.room
	end
end

return RoomDoorScript
