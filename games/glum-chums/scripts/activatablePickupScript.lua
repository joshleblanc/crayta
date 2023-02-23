local ActivatablePickupScript = {}

-- Script properties are defined here
ActivatablePickupScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "prerequisiteId", type = "string" },
	{ name = "questId", type = "string" },
	{ name = "singlePickup", type = "boolean", default = true },
	{ name = "id", type = "string" },
	{ name = "trigger", type = "entity" },
}

--This function is called on the server when this entity is created
function ActivatablePickupScript:Init()
	if #self.properties.id == 0 then 
		self.properties.id = self:GetEntity():GetName()
	end
end

function ActivatablePickupScript:ClientInit()
	local user = GetWorld():GetLocalUser()
	
	self:Schedule(function()
		print("Checking if quest is complete")
		user.documentStoresScript:GetDb("quest-system"):WaitForData()
		local quest = user.userQuestsScript:FindQuest(self.properties.questId)
		print("Found quest", self.properties.questId, quest:Progress(), quest:IsComplete())
	
		if quest:IsComplete() then 
			self:HideThing()
		end
	end)
end

function ActivatablePickupScript:HideThing()
	self.properties.trigger.interactable = false
	self:GetEntity():SendToScripts("SetVisibilityOff")
	print("Hiding pickup")
end

function ActivatablePickupScript:HandleInteract(player)
	local user = player:GetUser()
	local prereq = user.userQuestsScript:FindQuest(self.properties.prerequisiteId)
	local quest = user.userQuestsScript:FindQuest(self.properties.questId)
	local db = user.documentStoresScript:GetDb("pickups")
	
	if self.properties.singlePickup then 
		if db:FindOne({ _id = self.properties.id }) then 
			user:SendToScripts("Shout", "You've already collected that!")
			return
		end
	end
	
	if not prereq:IsComplete() then 
		user:SendToScripts("Shout", "You don't need that!")
		return
	end
	
	if quest:IsComplete() then 
		user:SendToScripts("Shout", "You don't need any more of that!")
		return
	end
	
	if self.properties.singlePickup then 
		db:InsertOne({ _id = self.properties.id })
	end
	
	quest:Complete()
	
	self:GetEntity().pickupSpawnerScript:OnInteract(player)
	
	user:SendToScripts("DoOnLocal", self:GetEntity(), "HideThing")
end

return ActivatablePickupScript
