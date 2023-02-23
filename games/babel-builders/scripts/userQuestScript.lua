local UserQuestScript = {}

-- Script properties are defined here
UserQuestScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "gameStorageController", type = "entity" }
}

UserQuestScript.Quests = {
	{ 
		wood = 0,
		stone = 1,
		instructions = "I've lost my favorite rock! Please get me another!",
		reward = 10
	},
	{
		wood = 10,
		stone = 0,
		instructions = "We're out of support beams, bring us more wood!",
		reward = 100
	},
	{
		wood = 10,
		stone = 10,
		instructions = "These toilets aren't going to build themselves!",
		reward = 200
	},
	{
		wood = 2,
		stone = 5,
		instructions = "We need material for benches!",
		reward = 70
	},
	{
		wood = 1,
		stone = 0,
		instructions = "I demand exactly 1 log!",
		reward = 10
	},
	{
		wood = 10,
		stone = 2,
		instructions = "Nobody told me the roof would need wood!",
		reward = 120
	}
		
}

--This function is called on the server when this entity is created

function UserQuestScript:Init()
	self.data = self:GetSaveData()
	
	print("Current Quest: ", self.data.currentQuest)
	if self.data.currentQuest and self.data.currentQuest > 0 then
		self:Show()
	end
	
	if not self.data.woodGathered then
		self.data.woodGathered = 0
	end
	if not self.data.stoneGathered then
		self.data.stoneGathered = 0
	end
	
	self:SetSaveData(self.data)
	
	self:UpdateCurrentQuest(self.data)
end

function UserQuestScript:HasQuest()
	self:GetEntity():SendToScripts("Debug", "Checking if quest exists: " .. tostring(self.data.currentQuest))
	return self.data.currentQuest and self.data.currentQuest > 0
end

function UserQuestScript:LocalInit()
	self.widget = self:GetEntity().userQuestWidget
end

function UserQuestScript:UpdateCurrentQuest(data)
	if IsServer() then
		self:SendToLocal("UpdateCurrentQuest", data)
		return	
	end
	
	if not data.currentQuest then
		return
	end
	
	if data.currentQuest <= 0 then
		return
	end
	
	local quest = UserQuestScript.Quests[data.currentQuest]
	print("Updating current quest", quest.wood)
	
	self.widget.js.data.instructions = quest.instructions
	self.widget.js.data.woodRequirement = quest.wood
	self.widget.js.data.stoneRequirement = quest.stone
	self.widget.js.data.stoneGathered = data.stoneGathered
	self.widget.js.data.woodGathered = data.woodGathered
	print("Reward: " .. tostring(quest.reward))
	self.widget.js.data.reward = quest.reward
end

function UserQuestScript:AssignNewQuest()
	self.data.currentQuest = math.random(1, #UserQuestScript.Quests)
	self.data.woodGathered = 0
	self.data.stoneGathered = 0
	self:SetSaveData(self.data)
	self:Show()
	self:UpdateCurrentQuest(self.data)
end

function UserQuestScript:CompleteQuest()
	local lastQuest = UserQuestScript.Quests[self.data.currentQuest]
	self.data.currentQuest = 0
	
	self:GetEntity():SendToScripts("AddNotification", "You completed a quest!")
	self:GetEntity():SendToScripts("AddNotification", "Gained " .. lastQuest.reward .. " gold")
	
	self:GetEntity():SendToScripts("AddGold", lastQuest.reward)
	
	self.properties.gameStorageController:SendToScripts("Update", FormatString("{1}-quests-completed", self:GetEntity():FindScriptProperty("team")), 1)
	
	self:GetEntity():SendXPEvent("quest")
	
	self:GetEntity():AddToLeaderboardValue("quests-completed", 1)
	self:GetEntity():AddToLeaderboardValue("gold-earned", lastQuest.reward)
	self:GetEntity().userWealthScript:Add(lastQuest.reward)
	
	self:SetSaveData(self.data)
		
	self:Hide()
	
	self:GetEntity().userSaveDataScript:Set("quest-last-used", GetWorld():GetUTCTime())
end

function UserQuestScript:IsQuestComplete() 
	local quest = UserQuestScript.Quests[self.data.currentQuest]
	if not quest then
		return false
	end
	return self.data.woodGathered >= quest.wood and self.data.stoneGathered >= quest.stone
end

function UserQuestScript:ProgressQuest(resource)
	local key = FormatString("{1}Gathered", resource)
	
	self.data[key] = self.data[key] + 1
	self:SetSaveData(self.data)
	
	self:UpdateWidget(key, self.data[key])
	
	if self:IsQuestComplete() then
		self:CompleteQuest()
	end
end

function UserQuestScript:Show() 
	if IsServer() then
		self:SendToLocal("Show")
		return
	end
	
	print("Showing quest board")
	
	self.widget:Show();
	self.widget.js.data.transparent = false
	self:Schedule(function()
		Wait(3)
		
		print("Setting quest board transparent")
		self.widget.js.data.transparent = true
	end)
	
end

function UserQuestScript:Hide()
	if IsServer() then
		self:SendToLocal("Hide")
		return
	end
	
	self.widget:Hide()
end


function UserQuestScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToLocal("UpdateWidget", key, value)
		return
	end
	
	self.widget.js.data[key] = value
end

return UserQuestScript
