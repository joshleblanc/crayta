local ActivatePickupsScript = {}

-- Script properties are defined here
ActivatePickupsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "prerequisiteId", type = "string" },
	{ name = "questId", type = "string" },
	{ name = "pickupId", type = "string" },
}

--This function is called on the server when this entity is created
function ActivatePickupsScript:Init()
	self:Schedule(function()
		while not self:GetEntity():IsLocalReady() do 
			Wait()
		end
	
		if #self.properties.prerequisiteId > 0 then 
			local prereq = self:GetEntity().userQuestsScript:FindQuest(self.properties.prerequisiteId)
			if prereq:IsComplete() then 
				self:Activate()
			end
		else 
			self:Activate()
		end
	end)
	
end

function ActivatePickupsScript:LocalInit()
	self.pickups = GetWorld():FindAllScripts("activatablePickupScript")
end

function ActivatePickupsScript:Activate()
	local quest = self:GetEntity().userQuestsScript:FindQuest(self.properties.questId)
	
	if quest:IsComplete() then return end 
	
	self:SendToLocal("LocalActivate")
end

function ActivatePickupsScript:LocalActivate()
	for _, pickup in ipairs(self.pickups) do 
		if pickup.properties.id == self.properties.pickupId then 
			pickup:GetEntity():SendToScripts("ShowPickup")
		end
		
	end
end

return ActivatePickupsScript
