local PickupIndicator = {}

-- Script properties are defined here
PickupIndicator.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "range", type = "number", default = 5000 },
	{ name = "effect", type = "entity" },
}

--This function is called on the server when this entity is created
function PickupIndicator:Init()
	self.trigger = self:GetEntity()
	
	local halfRange = self.properties.range / 2
	self.trigger.size = Vector.New(halfRange, halfRange, halfRange)
end

function PickupIndicator:ClientInit()
	self:Init()
	
	self.widget = self:GetEntity().pickupIndicatorWidget
	
	self.initialRotation = self:GetEntity():GetRotation()
	
	self.parent = self:GetEntity():GetParent()
	
	local user = GetWorld():GetLocalUser()
	local player = user:GetPlayer()
	if not player then return end 
	
	if self:GetEntity():IsOverlapping(player) then 
		self:ShowIndicator(user)
	end
	
end

function PickupIndicator:ClientOnTick()
	if not self.parent.physicsEnabled then return end 
	
	self:GetEntity():SetRotation(self.initialRotation)
end

function PickupIndicator:ShowIndicator(user)
	if GetWorld():GetLocalUser() ~= user then return end 
	
	self.properties.effect.visible = true
	self.widget.visible = true
end

function PickupIndicator:HideIndicator(user)
	if GetWorld():GetLocalUser() ~= user then return end 
	
	self.properties.effect.visible = false
	self.widget.visible = false
end

function PickupIndicator:OnTriggerEnter(player)
	self:GetEntity():SendToAllClients("ShowIndicator", player:GetUser())
end

function PickupIndicator:OnTriggerExit(player)
	self:GetEntity():SendToAllClients("HideIndicator", player:GetUser())
end

return PickupIndicator
