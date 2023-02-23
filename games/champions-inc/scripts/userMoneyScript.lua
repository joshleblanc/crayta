local UserMoneyScript = {}

-- Script properties are defined here
UserMoneyScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "defaultMoney", type = "number", default = 100 },
	{ name = "icon", type = "asset" },
	{ name = "moneyTemplate", type = "template" }
}

--This function is called on the server when this entity is created
function UserMoneyScript:Init()
	print("Initializing mooney")
	self.widget = self:GetEntity().userMoneyWidget
	self.widget.properties.iconUrl = self.properties.icon:GetIcon()
	
	self.inventory = self:GetEntity().inventoryScript

	local db = self:GetDb()

	if not self:GetDoc().moneyInitialized then 
		db:UpdateOne({ _id = self:GetDoc()._id }, {
			_set = {
				moneyInitialized = true,
				money = self.properties.defaultMoney
			}
		})
	end
	
	self:Schedule(function()
		Wait()
		if not self:GetDoc().moneyMigrated then 
			self.inventory:AddToInventory(self.properties.moneyTemplate, self:GetDoc().money)
			db:UpdateOne({ _id = self:GetDoc()._id }, {
				_set = {
					moneyMigrated = true
				}
			})
		end
		
		if not self:GetDoc().givenDefaultMoney then 
			self.inventory:AddToInventory(self.properties.moneyTemplate, self.properties.defaultMoney)
			db:UpdateOne({ _id = self:GetDoc()._id }, {
				_set = {
					givenDefaultMoney = true
				}
			})
		end
	end)
	
	
	
	self.widget.properties.money = self:GetMoney()
end

function UserMoneyScript:GetDb()
	return self:GetEntity().documentStoresScript:GetDb("default")
end

function UserMoneyScript:GetMoney()
	return self.inventory:GetTemplateCount(self.properties.moneyTemplate)
end

function UserMoneyScript:CanAfford(amt)
	return self:GetMoney() >= amt
end

function UserMoneyScript:AdjustMoney(amt)
	if not IsServer() then 
		self:SendToServer("AdjustMoney", amt)
		return
	end
	
	if amt > 0 then 
		self.inventory:AddToInventory(self.properties.moneyTemplate, amt)
	elseif amt < 0 then 
		self.inventory:RemoveTemplate(self.properties.moneyTemplate, -amt)
	end
	
	--[[
	self:GetDb():UpdateOne({}, {
		_inc = {
			money = amt
		}
	})
	--]]
	self:GetEntity():SetLeaderboardValue("most-money", self:GetMoney())
	
	self.widget.properties.money = self:GetMoney()
end

function UserMoneyScript:AddMoney(amt)
	self:AdjustMoney(amt)
	if amt ~= 0 then 
		self:GetEntity():SendToScripts("AddNotification", FormatString("You gained {1} money", amt))
	end
	
end

function UserMoneyScript:RemoveMoney(amt)
	self:AdjustMoney(-amt)
	if amt ~= 0 then 
		self:GetEntity():SendToScripts("AddNotification", FormatString("You spent {1} money", amt))
	end
end

function UserMoneyScript:GetDoc()
	return self:GetDb():FindOne()
end

return UserMoneyScript
