local MoodScript = {}

-- Script properties are defined here
MoodScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "happyMood", type = "entity", editable = false },
	{ name = "sadMood", type = "entity", editable = false },
	{ name = "questId", type = "string" },
}

--This function is called on the server when this entity is created
function MoodScript:Init()
end

function MoodScript:HandleQuestComplete(quest)
	if IsServer() then 
		self:SendToAllClients("HandleQuestComplete", quest)
		return
	end

	
	local user = GetWorld():GetLocalUser()
	if user ~= quest:GetEntity() then return end 
	
	if quest.properties.id ~= self.properties.questId then return end 
	
	self.properties.sadMood:SendToScripts("SetVisibilityOff")
	self.properties.happyMood:SendToScripts("SetVisibilityOn")
end

function MoodScript:OnUserLogin(user)
	self:Schedule(function()
		user.documentStoresScript:GetDb("quest-system"):WaitForData()
		user.userQuestsScript.properties.onQuestComplete:Listen(self, "HandleQuestComplete")
		if user.userQuestsScript:IsQuestComplete(self.properties.questId) then 
			while not user:IsLocalReady() do 
				Wait()
			end
			self:HandleQuestComplete(user.userQuestsScript:FindQuest(self.properties.questId))
		end
	end)
end

return MoodScript
