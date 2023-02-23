local UserResourceDepositScript = {}

-- Script properties are defined here
UserResourceDepositScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "instructions", type = "text" },
	{ name = "gameStorageController", type = "entity" }
}

function UserResourceDepositScript:HandleStorageUpdate(key, value)
	if IsServer() then 
		self:SendToLocal("HandleStorageUpdate", key, value)
		return
	end
	
	if not self.resourceDepositScript then return end 
	
	if key == self.resourceDepositScript:GetWoodId() or key == self.resourceDepositScript:GetStoneId() then
		self:UpdateWidgetFromScript(self.resourceDepositScript)
	end
end

function UserResourceDepositScript:LocalInit()
	self.widget = self:GetEntity().userResourceDepositWidget
end

function UserResourceDepositScript:Show(resourceDepositScript)
	if self.widget.visible then return end 
	
	self.resourceDepositScript = resourceDepositScript
	
	self:GetEntity():GetPlayer():SetInputLocked(true)
	
	self:UpdateWidgetFromScript(resourceDepositScript)
	
	self.widget:Show()
end

function UserResourceDepositScript:UpdateWidgetFromScript(resourceDepositScript)
	local storage = self.properties.gameStorageController.gameStorageControllerScript
	local level, wood, stone, statPercent = resourceDepositScript:GetLevel()
	
	print("user got level", level, wood, stone, statPercent)
	self.widget.js.data.title = resourceDepositScript.properties.name
	
	if not level then return end 
	
	self.widget.js.data.level = level.properties.level
	self.widget.js.data.wood = wood
	self.widget.js.data.stone = stone
	self.widget.js.data.requiredWood = level.properties.wood
	self.widget.js.data.requiredStone = level.properties.stone
	self.widget.js.data.stat = level.properties.stat
	self.widget.js.data.percent = statPercent - level.properties.statPercent
	self.widget.js.data.nextStat = level.properties.stat
	self.widget.js.data.nextPercent = level.properties.statPercent
end

function UserResourceDepositScript:Hide()
	self.widget:Hide()
	
	self:GetEntity():GetPlayer():SetInputLocked(false)
	self.resourceDepositScript = nil
end

function UserResourceDepositScript:LocalOnButtonPressed(btn)
	if btn == "interact" then
		self:Schedule(function()
			Wait()
			self:Hide()
		end)
	end
end

return UserResourceDepositScript
