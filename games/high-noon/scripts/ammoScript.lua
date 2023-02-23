local AmmoScript = {}

-- Script properties are defined here
AmmoScript.Properties = {
	-- Example property
	{ name = "ammoPickupSound", type = "soundasset"},
	{ name = "gunTemplate", type = "template" },
	{ name = "highNoonController", type = "entity" }
}

function AmmoScript:AddAmmo(player, fromEntity)
	local heldEntity = player:FindScriptProperty("heldEntity")
	local pickupSpawnerScript = fromEntity:FindScript("pickupSpawnerScript", true)
	if heldEntity and heldEntity:GetTemplate() == self.properties.gunTemplate then
		local props = heldEntity.gunScript.properties
		if props.currentShotsInClip < props.shotsPerClip then
			heldEntity.gunScript:AddAmmo()
			player:PlaySound(self.properties.ammoPickupSound)
			if pickupSpawnerScript.properties.singlePickup then
				pickupSpawnerScript:Remove()
			end
		else
			pickupSpawnerScript:SendToScript("ShowPickup")
			player:GetUser():SendToScripts("Shout", "Your ammo is full!")
		end
	else
		local item = player:GetUser().inventoryScript:FindItemForTemplate(self.properties.gunTemplate)
		local currentShotsInClip = item.data.currentShotsInClip or 0
		local shotsPerClip = item.template:FindScriptProperty("shotsPerClip")
		if currentShotsInClip < shotsPerClip then
			item.data.currentShotsInClip = currentShotsInClip + 1
			player:PlaySound(self.properties.ammoPickupSound)
			if pickupSpawnerScript.properties.singlePickup then
				pickupSpawnerScript:Remove()
			end
		else
			pickupSpawnerScript:SendToScript("ShowPickup")
			player:GetUser():SendToScripts("Shout", "Your ammo is full!")
		end
	end
	
	if self.properties.highNoonController.HighNoonControllerScript:IsDestroy() then
		player:GetUser():SendToScripts("EquipGun")
	end
end

return AmmoScript
