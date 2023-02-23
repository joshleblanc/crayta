local UserMoneyScript = {}

-- Script properties are defined here
UserMoneyScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "money", type = "number", default = 0 },
	{ name = "moneySound", type = "soundasset"},
	{ name = "onAddMoney", type = "event" }
}

--This function is called on the server when this entity is created
function UserMoneyScript:Init()
	local data = self:GetSaveData()
	self.properties.money = data.money
	self:LocalUpdateMoney(self.properties.money)
end

function UserMoneyScript:AddMoney(money, msg, playSound)
	if not IsServer() then
		self:SendToServer("AddMoney", money, msg, playSound)
		return
	end
	
	if msg then
		self:GetEntity():SendToScripts("Shout", msg)
	end
	
	if playSound then
		self:GetEntity():GetPlayer():PlaySound(self.properties.moneySound)
	end
	
	if money > 0 then 
		self:GetEntity():AddToLeaderboardValue("coins-earned", money)
		self:GetEntity():AddToLeaderboardValue("coins-earned-weekly", money)
		self:GetEntity():SendToScripts("AddNotification", FormatString("You gained {1} coin(s)", money))
	else
		self:GetEntity():SendToScripts("AddNotification", FormatString("You spent {1} coin(s)", math.abs(money)))
	end

	self.properties.money = self.properties.money + money
	self:SetSaveData({ money = self.properties.money })

	self:LocalUpdateMoney(self.properties.money)
	self.properties.onAddMoney:Send(money, msg, self.properties.money)
end

function UserMoneyScript:LocalUpdateMoney(money)
	if IsServer() then
		self:SendToLocal("LocalUpdateMoney", money)
		return
	end
	
	self:GetEntity().userMoneyWidget.js.data.money = money
end

function UserMoneyScript:RemoveMoney(money, msg)
	self:AddMoney(-money, msg)
end

function UserMoneyScript:CanAfford(amount)
	return self.properties.money >= amount
end

function UserMoneyScript:GetMoneyAmount()
	return self.properties.money or 0
end

return UserMoneyScript
