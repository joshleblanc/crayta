local ClearInventory = {}

-- Script properties are defined here
ClearInventory.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ClearInventory:Init()
	self:GetEntity():GetUser().inventoryScript:SendToScript("Reset")
end

return ClearInventory
