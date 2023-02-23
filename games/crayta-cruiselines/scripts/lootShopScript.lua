local LootShopScript = {}

-- Script properties are defined here
LootShopScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "interactPrompt", type = "text" },
	{ name = "lootbox", type = "entity" },
}

--This function is called on the server when this entity is created
function LootShopScript:Init()
end

function LootShopScript:GetInteractPrompt(prompts)
	prompts.interact = self.properties.interactPrompt
end

function LootShopScript:HandleInteract(player)
	local user = player:GetUser()
	
	self.properties.lootbox.lootboxScript:Play(user)
end

return LootShopScript
