local XpCheatScript = {}

-- Script properties are defined here
XpCheatScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "xpTemplate", type = "template" },
	{ name = "amount", type = "number", default = 1000 },
}

--This function is called on the server when this entity is created
function XpCheatScript:Init()
end

function XpCheatScript:GiveXp()
	self:GetEntity().inventoryScript:AddToInventory(self.properties.xpTemplate, self.properties.amount)
end

return XpCheatScript
