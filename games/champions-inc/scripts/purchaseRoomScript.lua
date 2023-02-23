local PurchaseRoomScript = {}

-- Script properties are defined here
PurchaseRoomScript.Properties = {
	-- Example property
	{name = "purchaseSound", type = "soundasset"},
	{name = "onPurchaseRoom", type = "event" }
}

local COSTS = {
	100,
	1000,
	2500,
	5000,
	10000
}

--This function is called on the server when this entity is created
function PurchaseRoomScript:Init()
	self.widget = self:GetEntity().purchaseRoomWidget
end

function PurchaseRoomScript:SetRoom(room)
	self.open = true
	self.room = room
	--self.widget.properties.name = room.properties.name
	self.widget.properties.price = self:GetPrice()
	self.widget.properties.canAfford = self:GetEntity().userMoneyScript:CanAfford(self:GetPrice())
	
	self.widget:Show()
end

function PurchaseRoomScript:GetPrice()
	local roomCount = #self:GetEntity().documentStoresScript:GetDb("rooms"):Find()
	
	return COSTS[roomCount + 1]
end

function PurchaseRoomScript:UnsetRoom()
	self.open = false
	self.room = nil
	self.widget:Hide()
end

function PurchaseRoomScript:PurchaseRoom()
	self:GetEntity().documentStoresScript:UseDb("rooms", function(db)		
		local child = self.room:GetChild()
		local entity = GetWorld():Spawn(self.room.properties.defaultTemplate, self.room:GetEntity():GetPosition(), self.room:GetEntity():GetRotation())
		
		entity:AttachTo(self.room:GetEntity())
		entity:SetPosition(self.room:GetEntity():GetPosition())
		entity:SetRotation(self.room:GetEntity():GetRotation())
		
		entity:SendToScripts("SetOwner", self:GetEntity())
		entity:SendToScripts("SetBaseRoom", self.room)
		child:Destroy()
		
		self:GetEntity().userMoneyScript:RemoveMoney(self:GetPrice())
		self:GetEntity():GetPlayer():PlaySound(self.properties.purchaseSound)	
		
		local tmpRoom = db:InsertOne({ 
			_id = self.room.properties.id,
			templateName = self.room.properties.defaultTemplate:GetName()
		})
		
		print("room id", tmpRoom._id)
		print(#db:Find())	
		
		self.room = nil
		self.widget:Hide()
		
		print("Showing widget on child", child:GetName())
		child:SendToScripts("ShowWidget")
		
		self.properties.onPurchaseRoom:Send(self:GetEntity())
	end)
end

function PurchaseRoomScript:OnButtonPressed(btn)
	if btn == "interact" and self.open and self:GetEntity().userMoneyScript:CanAfford(self:GetPrice()) then 
		self:PurchaseRoom()
	end
end

return PurchaseRoomScript
