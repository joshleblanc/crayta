local PurchaseRoomTriggerScript = {}

-- Script properties are defined here
PurchaseRoomTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "trigger", type = "entity" }
}

--This function is called on the server when this entity is created
function PurchaseRoomTriggerScript:Init()
	self.properties.trigger.onTriggerEnter:Listen(self, "HandleTriggerEnter")
	self.properties.trigger.onTriggerExit:Listen(self, "HandleTriggerExit")
end

function PurchaseRoomTriggerScript:SetBaseRoom(room)
	self.room = room
end

function PurchaseRoomTriggerScript:HandleTriggerEnter(player)
	if player:IsA(Character) then 
		player:GetUser().purchaseRoomScript:SetRoom(self.room)
	end
end

function PurchaseRoomTriggerScript:HandleTriggerExit(player)
	if player:IsA(Character) then 
		player:GetUser().purchaseRoomScript:UnsetRoom()
	end
end

return PurchaseRoomTriggerScript
