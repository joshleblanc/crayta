local BaseScript = {}

-- Script properties are defined here
BaseScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "heroSelect", type = "entity" }
}

--This function is called on the server when this entity is created
function BaseScript:Init()
	self.location = self:GetEntity().locationScript
	
	self.rooms = self:GetEntity():FindAllScripts("baseRoomScript", true)
	
	print("rooms: ", #self.rooms)
	
end

function BaseScript:HandleLocationSpawn(owner)
	owner.documentStoresScript:UseDb("rooms", function(db)
		for _, room in ipairs(self.rooms) do 
			local roomSettings = db:FindOne({ _id = room.properties.id })
			
			print("Room setting", roomSettings, room.properties.id, #db:Find())
			
			local template
			if roomSettings then 
				template = GetWorld():FindTemplate(roomSettings.templateName)
			else
				template = room.properties.unpurchasedTemplate
			end
			local entity = GetWorld():Spawn(template, room:GetEntity():GetPosition(), room:GetEntity():GetRotation())
			entity:AttachTo(room:GetEntity())
			entity:SetPosition(room:GetEntity():GetPosition())
			entity:SetRotation(room:GetEntity():GetRotation())
			
			room:SetChild(entity)
			entity:SendToScripts("SetBaseRoom", room)
			entity:SendToScripts("SetOwner", owner)
		end
	end)
	
end

return BaseScript
