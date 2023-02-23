local UserWinScript = {}

-- Script properties are defined here
UserWinScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserWinScript:Init()
end

function UserWinScript:LocalInit()
	self.widget = self:GetEntity().userWinWidget
end

function UserWinScript:ShowTeam1Win()
	if IsServer() then
		self:SendToLocal("ShowTeam1Win")
		return
	end
	
	self:WidgetStuff()

	self.widget.js.data.msg = "East Craytasia wins!"
	self.widget:Show()
end

function UserWinScript:ShowTeam2Win()
	if IsServer() then
		self:SendToLocal("ShowTeam2Win")
		return
	end
	self:WidgetStuff()
	
	self.widget.js.data.msg = "West Craytasia wins!"
	self.widget:Show()
end

function UserWinScript:WidgetStuff()
	self:GetEntity().userGoldWidget.visible = false
	self:GetEntity().userTeamWidget.visible = false
	
	local qVisible = self:GetEntity().userQuestWidget.visible 
	
	self:GetEntity().userQuestWidget.visible = false
	self:GetEntity().teamResourcesWidget.visible = false
	self:GetEntity().wealthBarWidget.visible = false
	
	self:GetEntity().userSaveDataScript:Set("gold", 0)
	
	self:Schedule(function()
		Wait(10)
		
		self:GetEntity().userGoldWidget.visible = true
		self:GetEntity().userTeamWidget.visible = true
		self:GetEntity().userQuestWidget.visible = qVisible
		self:GetEntity().teamResourcesWidget.visible = true
		self:GetEntity().wealthBarWidget.visible = true
		
		self:GetEntity().userWinWidget.visible = false
		
		self:ResetCamera()
	end)
end

function UserWinScript:ResetCamera()
	if not IsServer() then 
		self:SendToServer("ResetCamera")
		return
	end
	self:GetEntity():SetCamera(self:GetEntity():GetPlayer(), 1)
end

return UserWinScript
