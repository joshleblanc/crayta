local CompanionSpeakScript = {}

-- Script properties are defined here
CompanionSpeakScript.Properties = {
	-- Example property
	{name = "speakingText", type = "string"},
	{name = "questId", type = "string" },
	
}

--This function is called on the server when this entity is created
function CompanionSpeakScript:Init()
end

function CompanionSpeakScript:OnInteract(player)
	local user = player:GetUser()
	self:LaunchHint(user)
end

function CompanionSpeakScript:GetInteractPrompt(prompts)
	prompts.interact = "Talk"
end

function CompanionSpeakScript:OnTriggerEnter(player)
	if not player:IsA(Character) then return end 
	
	local user = player:GetUser()
	local quests = user.userQuestsScript
	
	if #self.properties.questId > 0 then 
		if not quests:IsQuestComplete(self.properties.questId) then 
			self:LaunchHint(user)
			quests:CompleteQuest(self.properties.questId)
		end
	else
		self:LaunchHint(user)
	end
end

function CompanionSpeakScript:LaunchHint(user)
	user:SendToScripts("Speak", self.properties.speakingText)
end

return CompanionSpeakScript
