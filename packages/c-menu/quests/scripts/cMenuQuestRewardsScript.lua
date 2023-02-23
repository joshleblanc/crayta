local CMenuQuestRewardsScript = {}

-- Script properties are defined here
CMenuQuestRewardsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function CMenuQuestRewardsScript:Init()
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	local quests = self.user.userQuestsScript
	quests.properties.onQuestComplete:Listen(self, "HandleQuestComplete")
end

function CMenuQuestRewardsScript:LocalInit()
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	local quests = self.user.userQuestsScript
	self.widget = self:GetEntity().cMenuQuestRewardsWidget
	
	self:Schedule(function()
		self.widget.js:CallFunction("InitializeRewards")
		
		Wait(1)
		
		local rewards = quests:GetUnclaimedRewards()
		
		for _, reward in ipairs(rewards) do 
			self.widget.js:CallFunction("AddReward", reward)
		end
	end)
end

function CMenuQuestRewardsScript:HandleQuestComplete(quest)
	if IsServer() then 
		self:SendToLocal("HandleQuestComplete", quest)
		return
	end
	
	print("Handling quest completion", quest.properties.id, quest:HasRewards(), #quest:GetRewards())
	if quest:HasRewards() then 
		self.widget.js:CallFunction("AddReward", {
			id = quest.properties.id,
			rewards = quest:GetRewards()
		})
	end
end

function CMenuQuestRewardsScript:CMenuClaimRewards(id) 
	if not IsServer() then 
		self:SendToServer("CMenuClaimRewards", id)
		return
	end
	
	local rewards = self.user.userQuestsScript:GetQuestRewards(id)
	
	for _, reward in ipairs(rewards) do 
		self.user:SendToScripts("AddToInventory", reward.properties.template, reward.properties.quantity)
	end
	
	self.user.userQuestsScript.db:UpdateOne({ _id = id }, {
		_set = {
			claimedRewards = true
		}
	})
end

return CMenuQuestRewardsScript
