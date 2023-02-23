local GiveDroneCheatScript = {}

-- Script properties are defined here
GiveDroneCheatScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "template", type = "template" },
}

--This function is called on the server when this entity is created
function GiveDroneCheatScript:Init()
end

function GiveDroneCheatScript:GiveDrone()
	self:GetEntity().inventoryScript:AddToInventory(self.properties.template, 1)
end

return GiveDroneCheatScript
