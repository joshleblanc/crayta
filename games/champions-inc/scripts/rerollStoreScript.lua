local RollStoreScript = {}

-- Script properties are defined here
RollStoreScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "storeEntity", type = "entity" },
	{ name = "trigger", type = "entity" }
}

--This function is called on the server when this entity is created
function RollStoreScript:Init()
	self.properties.trigger.onTriggerEnter:Listen(self, "HandleTriggerEnter")
	self.properties.trigger.onTriggerExit:Listen(self, "HandleTriggerExit")
end

function RollStoreScript:HandleTriggerEnter(player)
	print("Roll store trigger enter", self.properties.storeEntity)
	if player and player:IsA(Character) then 
		player:GetUser().rerollPromptScript:Show(self)
	end
end

function RollStoreScript:HandleTriggerExit(player)
	print("Roll store trigger exit", self.properties.storeEntity)

	if player and player:IsA(Character) then 
		player:GetUser().rerollPromptScript:Hide()
	end
end

function RollStoreScript:RerollHeroes()
	print("Roll store reroll", self.properties.storeEntity)

	self.properties.storeEntity:SendToScripts("RerollHeroes")	
end

return RollStoreScript
