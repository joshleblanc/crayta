local PurchaseHeroScript = {}

-- Script properties are defined here
PurchaseHeroScript.Properties = {
	-- Example property
	{name = "purchaseSound", type = "soundasset"},
	{ name = "onPurchaseHero", type = "event" }
}

--This function is called on the server when this entity is created
function PurchaseHeroScript:Init()
	self.widget = self:GetEntity().purchaseHeroWidget
	self.open = false
end

function PurchaseHeroScript:SetHero(heroScript)
	self.open = true
	self.heroScript = heroScript
	self.widget.properties.name = heroScript.properties.name 
	self.widget.properties.description = heroScript.properties.description
	self.widget.properties.price = heroScript:GetPrice()
	self.widget.properties.purchased = heroScript.properties.purchased
	self.widget.properties.canAfford = self:GetEntity().userMoneyScript:CanAfford(heroScript:GetPrice())
	self.widget.properties.rarity = heroScript:GetRarity()
	self:SetPurchaseStats(self.heroScript)
	
	self.widget:Show()
end

function PurchaseHeroScript:SetPurchaseStats(heroScript)
	if IsServer() then 
		self:SendToLocal("SetPurchaseStats", heroScript)
		return
	end
	
	self:GetEntity().purchaseHeroWidget.js.data.stats = heroScript:StatWidgetData()
end

function PurchaseHeroScript:UnsetHero()
	self.open = false
	self.heroScript = nil
	self.widget:Hide()
end

function PurchaseHeroScript:OnButtonPressed(btn)
	if btn == "interact" and self.heroScript and not self.heroScript.properties.purchased and self.open and self:GetEntity().userMoneyScript:CanAfford(self.heroScript:GetPrice()) and not self.heroScript.purchased then 
		self:GetEntity():GetPlayer():PlaySound(self.properties.purchaseSound)
		self.heroScript:SetPurchased(true)
		self.widget.properties.purchased = true
		self.widget.properties.canAfford = self:GetEntity().userMoneyScript:CanAfford(self.heroScript:GetPrice())
		self:GetEntity().userMoneyScript:RemoveMoney(self.heroScript:GetPrice())
		self:GetEntity().userHeroesScript:AddHero(self.heroScript)	
		
		self:GetEntity():SendXPEvent("buy-a-hero")
		
		self.properties.onPurchaseHero:Send(self:GetEntity())
	end
end

return PurchaseHeroScript
