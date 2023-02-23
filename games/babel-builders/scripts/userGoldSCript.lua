local UserGoldScript = {}

-- Script properties are defined here
UserGoldScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "gameStorageController", type = "entity" }
}

--This function is called on the server when this entity is created
function UserGoldScript:Init()
	self.data = self:GetSaveData()
	if not self.data.gold then
		self.data.gold = 0
		self:SetSaveData(self.data)
	end
	
	self:UpdateWidget("gold", self.data.gold)
end

function UserGoldScript:LocalInit()
	self.widget = self:GetEntity().userGoldWidget
end

function UserGoldScript:AddGold(amt)
	self.data.gold = self.data.gold + amt
	self:SetSaveData(self.data)
	
	self:UpdateWidget("gold", self.data.gold)
	
	local team = self:GetEntity():FindScriptProperty("team")
	
	self.properties.gameStorageController:SendToScripts("Update", FormatString("{1}-gold", team), amt)
end

function UserGoldScript:RemoveGold(amt)
	self.data.gold = self.data.gold - amt
	self:SetSaveData(self.data)
	
	self:UpdateWidget("gold", self.data.gold)
	
	self.properties.gameStorageController:SendToScripts("Update", FormatString("{1}-gold", team), -amt)
end

function UserGoldScript:CanAfford(amt)
	return self.data.gold >= amt
end

function UserGoldScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToLocal("UpdateWidget", key, value)
		return 
	end
	
	self.widget.js.data[key] = value
end

return UserGoldScript
