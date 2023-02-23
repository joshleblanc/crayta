local PlayerInitializationScript = {}

PlayerInitializationScript.Properties = {
}

function PlayerInitializationScript:Init()
	self:GetEntity():GetUser().inventoryScript:EquipPickaxe()
	--self:GetEntity().collisionPreset = 6
	--self:GetEntity().collisionEnabled = true
end

function PlayerInitializationScript:DisableCollision()
	print("Disabling collision on {1}", self:GetEntity():GetUser():GetUsername())
	--self:GetEntity().collisionEnabled = false
end

return PlayerInitializationScript