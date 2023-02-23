local CombobulatorScript = {}

-- Script properties are defined here
CombobulatorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "requiredItems", type = "template", container = "array" },
	{ name = "requiredQuest", type = "string" },
	{ name = "brokenEffects", type = "entity", container = "array" },
	
}

--This function is called on the server when this entity is created
function CombobulatorScript:ClientInit()
	local user = GetWorld():GetLocalUser()
	self:Schedule(function()
		user.documentStoresScript:GetDb("quest-system"):WaitForData()
		if self:IsComplete() then 
			self:DisableEffects()
		end
	end)

end

function CombobulatorScript:IsComplete()
	local user = GetWorld():GetLocalUser()
	local quest = user.userQuestsScript:FindQuest(self.properties.requiredQuest)
	return quest:IsComplete()
end

function CombobulatorScript:DisableEffects()
	for i=1,#self.properties.brokenEffects do 
		self.properties.brokenEffects[i].active = false
	end
end

function CombobulatorScript:OpenRecipeList(user)
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "OpenRecipeList", user)
		return
	end
	
	user:GetPlayer().cMenuRecipesScript:OpenForRecipeList("molecules")
end

function CombobulatorScript:OnInteract(player)
	local user = player:GetUser()

	local quest = user.userQuestsScript:FindQuest(self.properties.requiredQuest)
	if quest:IsComplete() then 
		self:OpenRecipeList(user)
	else 
		local good = true
		for i=1,#self.properties.requiredItems do 
			if not user.inventoryScript:FindItemForTemplate(self.properties.requiredItems[i]) then 
				good = false
			end
		end
		
		if good then
			for i=1,#self.properties.requiredItems do 
				user.inventoryScript:RemoveTemplate(self.properties.requiredItems[i])
			end
			
			quest:Complete()
			self:DisableEffects()
			self:OpenRecipeList(user)
		end
	end
end

return CombobulatorScript
