local RerollPromptScript = {}

-- Script properties are defined here
RerollPromptScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "cost", type = "number" }
}

--This function is called on the server when this entity is created
function RerollPromptScript:Init()
	self.widget = self:GetEntity().rerollPromptWidget
	self.widget.properties.cost = self.properties.cost
end

function RerollPromptScript:Show(rerollScript)
	self.open = true
	self.rerollScript = rerollScript
	self.widget.properties.canAfford = self:GetEntity().userMoneyScript:CanAfford(self.properties.cost)
	self.widget:Show()
end

function RerollPromptScript:Hide()
	self.open = false
	self.rerollScript = nil
	self.widget:Hide()
end

function RerollPromptScript:OnButtonPressed(btn)
	if not self.open then return end 
	if btn ~= "interact" then return end 
	
	self:PerformReroll()
end

function RerollPromptScript:PerformReroll()
	if self:GetEntity().userMoneyScript:CanAfford(self.properties.cost) then 
		self:GetEntity().userMoneyScript:RemoveMoney(self.properties.cost)
		self.rerollScript:RerollHeroes()	
	end
end

return RerollPromptScript
