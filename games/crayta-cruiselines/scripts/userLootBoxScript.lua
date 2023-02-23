local UserLootBoxScript = {}

-- Script properties are defined here
UserLootBoxScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "asset", type = "asset" },
	{ name = "invalidSound", type = "soundasset" },
	{ name = "price", type = "number", default = 2 },
	{ name = "duplicateReward", type = "number", default = 1 },
	{ name = "onDecorationUnlock", type = "event" },
	{ name = "moneyAsset", type = "asset" },
	{ name = "newItemSound", type = "soundasset" }
}

--This function is called on the server when this entity is created
function UserLootBoxScript:Init()
end

function UserLootBoxScript:LocalInit()
	self.widget = self:GetEntity().userLootBoxWidget
	self.widget.js.data.money = self:GetEntity().userMoneyScript:GetMoneyAmount()
	self.duplicateReward = self:GetEntity():FindScript("lootboxItemScript")
	self.widget.js.data.price = self.properties.price
	self.widget.js.data.moneyIcon = self.properties.moneyAsset:GetIcon()
	self.widget:Hide()
end

function UserLootBoxScript:StartRevealing()
	self.widget.js.data.revealing = true
	self.widget.js.data.revealed = false
end

function UserLootBoxScript:Owns(item)
	return self:GetEntity().saveDataScript:GetData("loot-box-{1}", item.properties.id)
end

function UserLootBoxScript:HandleMoneyChange(amt, msg, total)
	if IsServer() then
		self:SendToLocal("HandleMoneyChange", amt, msg, total)
		return
	end
	
	self.widget.js.data.money = total
end

function UserLootBoxScript:Claim(item)
	self:GetEntity().saveDataScript:SaveData(FormatString("loot-box-{1}", item.properties.id), true)
	self:SendToServer("FireUnlockEvent", item.properties.id)
end

function UserLootBoxScript:FireUnlockEvent(id)
	print("Sending unlock event", id)
	self.properties.onDecorationUnlock:Send(id)
end

function UserLootBoxScript:Buy()
	if self:GetEntity().userMoneyScript:CanAfford(self.properties.price) then
		self:GetEntity():SendToScripts("RemoveMoney", self.properties.price)
		local item = self.lootbox:FindItem()
		if self:Owns(item) then
			self:Reveal(self.duplicateReward)
		else
			self:Claim(item)
			self:Reveal(item)
		end
	else
		self:GetEntity():PlaySound2D(self.properties.invalidSound)
	end
end

function UserLootBoxScript:Close()
	self:GetEntity().userHudScript:Enable()
	self:GetEntity().userMapScript:Enable()
	self.widget:Hide()
	self:SendToServer("ResetCamera")
end

function UserLootBoxScript:Show(lootbox)
	self:GetEntity().userHudScript:Disable()
	self:GetEntity().userMapScript:Disable()
	self.lootbox = lootbox
	self.widget:Show()
end

function UserLootBoxScript:Hide()
	self.widget:hide()
end

function UserLootBoxScript:Reveal(item)
	self.widget.js.data.revealing = true
	self.widget.js.data.revealed = false 
	
	self.widget.js.data.icon = item.properties.mesh:GetIcon()
	self.widget.js.data.name = item.properties.name
	
	
	self:Schedule(function()

		Wait(self.lootbox:Open())
		
		if item == self.duplicateReward then
			self:GetEntity():SendToScripts("AddMoney", self.properties.duplicateReward)
		else
			self:SendToServer("Notify", item)
			self:GetEntity():PlaySound2D(self.properties.newItemSound)
		end
		
		self.widget.js.data.revealed = true
		self.widget.js.data.revealing = false
		self.lootbox:PlayRevealSound()
		Wait(3)
		self.lootbox:Close()
		
		self.widget.js.data.revealed = false
	end)
end

function UserLootBoxScript:Notify(item)
	local you = self:GetEntity()
	GetWorld():ForEachUser(function(user)
		if user == you then
			user:SendToScripts("AddNotification", Text.Format("You got a {1}", item.properties.name))
		else
			user:SendToScripts("AddNotification", Text.Format("{1} got a {2} from the souvenir shop!", tostring(you:GetUsername()), item.properties.name))
		end
	end)
end

function UserLootBoxScript:ResetCamera()
	self:GetEntity():SetCamera(self:GetEntity():GetPlayer())
end

return UserLootBoxScript
