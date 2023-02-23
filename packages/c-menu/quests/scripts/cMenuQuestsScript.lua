local CMenuQuestsScript = {}

-- Script properties are defined here
CMenuQuestsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function CMenuQuestsScript:Init()
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	self.questsScript = self.user.userQuestsScript
end

function CMenuQuestsScript:LocalInit()
	self.menuOption = self:GetEntity().cMenuScript:FindOption("Quests")
	
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	self.questsScript = self.user.userQuestsScript
	self.widget = self:GetEntity().cMenuQuestsWidget
	
	self.questTrackerScript = self:GetEntity().cMenuQuestsTrackerScript
	
	self.menuOption.properties.onOpen:Listen(self, "HandleWidgetOpen")
end

function CMenuQuestsScript:CMenuToggleQuestTracking(id)
	self.questsScript:ToggleQuestTracking(id)
	self:UpdateQuestsWidget()
	
	if self.questTrackerScript then 
		self.questTrackerScript:UpdateTracker()
	end
end

function CMenuQuestsScript:CMenuOpenSpecificQuest(id)
	local menu = self:GetEntity().cMenuScript
	menu:OpenMenuOption("Quests")
	
	self.widget.js:CallFunction("ActivateSpecificQuest", id)
end

function CMenuQuestsScript:HandleWidgetOpen()
	self:UpdateRecentQuests()
	self:UpdateQuestsStructure()
	self:UpdateQuestsWidget()
end

function CMenuQuestsScript:UpdateRecentQuests()
	if IsServer() then 
		self:SendToLocal("UpdateRecentQuests")
		return
	end
	
	local recentQuests = self.questsScript:RecentlyCompleted()
	
	self.widget.js.data.recentlyCompleted = recentQuests
	self.widget.js.data.score = self.questsScript:Score()
end

function CMenuQuestsScript:UpdateQuestsStructure()
	if IsServer() then 
		self:SendToLocal("UpdateQuestsStructure")
		return
	end
	
	local structure = self.questsScript:GetStructure()
	
	self.widget.js:CallFunction("UpdateStructure", structure)
	--self.widget.js.data.structure = structure
end

function CMenuQuestsScript:UpdateQuestsWidget()
	if IsServer() then 
		self:SendToLocal("UpdateQuestsWidget")
		return
	end
	
	local widgetData = self.questsScript:GetWidgetData()
	
	self.widget:CallFunction("InitQuestsTransfer")
	for _, datum in ipairs(widgetData) do 
		self.widget:CallFunction("AddQuest", datum)
	end
	self.widget:CallFunction("FinishQuestsTransfer")
end

return CMenuQuestsScript
