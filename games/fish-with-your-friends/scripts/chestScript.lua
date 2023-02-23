local ChestScript = {}

-- Script properties are defined here
ChestScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "numItems", type = "number", default = 1 },
	{ name = "active", type = "boolean", default = true },
	{ name = "rechargeTime", type = "number", default = 60 },
}

--This function is called on the server when this entity is created
function ChestScript:Init()
end

function ChestScript:OnInteract(player)
	if not self.properties.active then return end 
	self.properties.active = false
	
	self:GetEntity():PlayAnimation("Opening")
	
	self:Schedule(function()
		Wait(self.properties.rechargeTime)
		self:GetEntity():PlayAnimation("Closing")
		self.properties.active = true
	end)
	
	player:GetUser():SendToScripts("DoOnLocal", self:GetEntity(), "TryOpen")
	local items = {}
	
	for i=1,self.properties.numItems do 
		local item = self:GetEntity().lootTableScript:FindItemByChance()
		
		local datum = items[item:GetName()] or { count = 0, item = item }
		datum.count = datum.count + 1
		
		items[item:GetName()] = datum
	end
	
	for k,v in pairs(items) do 
		player:GetUser():SendToScripts("AddToInventory", v.item, v.count)
	end
end

return ChestScript
