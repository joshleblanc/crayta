local HealScript = {}

-- Script properties are defined here
HealScript.Properties = {
	-- Example property
	{ name = "amount", type = "number" }
}

function HealScript:Heal(player, fromEntity)
	local healthScript = player.healthScript
	
	if healthScript.properties.hp == healthScript.properties.maxHp then
		fromEntity.pickupSpawnerScript:SendToScript("ShowPickup")
	else
		healthScript:SendToScript("Heal", self.properties.amount, fromEntity)
	end
	
end

return HealScript
