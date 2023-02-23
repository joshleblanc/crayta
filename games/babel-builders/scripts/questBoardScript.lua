local QuestBoardScript = {}

-- Script properties are defined here
QuestBoardScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "reuseTime", type = "number", default = 60, tooltip = "In seconds" }
}

--This function is called on the server when this entity is created
function QuestBoardScript:Init()
end

function QuestBoardScript:ClientInit()
	self.widget = self:GetEntity().questBoardWidget
end

function QuestBoardScript:OnTick()
	GetWorld():ForEachUser(function(user) 
		local timeRemaining = self:TimeRemaining(user)
		user:SendToScripts("DoOnLocal", self:GetEntity(), "UpdateTimer", timeRemaining)
	end)
end

function QuestBoardScript:UpdateTimer(timeRemaining)
	if timeRemaining <= 0 then
		self.widget:Hide()
	else
		self.widget:Show()
		
		local minutes = math.floor(timeRemaining / 60)
		local seconds = timeRemaining - (minutes * 60)
		
		self.widget.js.data.timer = string.format("%02d:%02d", minutes, seconds)
	end
end

function QuestBoardScript:GetInteractPrompt(prompts)
	prompts.interact = "Claim a quest!"
end

function QuestBoardScript:TimeRemaining(user)
	local lastUsed = user.userSaveDataScript:Get("quest-last-used")
	if lastUsed then
		return self.properties.reuseTime - (GetWorld():GetUTCTime() - lastUsed)
	else
		return 0
	end
end

function QuestBoardScript:OnInteract(player)
	local user = player:GetUser()
	
	local timeRemaining = self:TimeRemaining(user)
	
	if user.userQuestScript:HasQuest() then
		user:SendToScripts("Shout", "You already have a quest!")
	elseif timeRemaining > 0 then
		user:SendToScripts("Shout", FormatString("Wait {1} seconds before using this again!", timeRemaining))
	else
		player:GetUser():SendToScripts("AssignNewQuest")
	end
end

return QuestBoardScript
