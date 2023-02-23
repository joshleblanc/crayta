local HospitalHealScript = {}

-- Script properties are defined here
HospitalHealScript.Properties = {
	-- Example property
	{name = "healSound", type = "soundasset",},
	{name = "healEffect", type = "effectasset",},
	{ name = "hospitalId", type = "string" },
}

--This function is called on the server when this entity is created
function HospitalHealScript:Init()
end

function HospitalHealScript:OnTriggerEnter(player)
	player:GetUser():SendToScripts("DoOnLocal", self:GetEntity(), "Heal", player)
end

function HospitalHealScript:Heal(player)
	player:GetUser():SendToScripts("LocalConfirm", "Do you want to heal your monsters?", function(response)
		if response then 
			self:HealMonsters(player)
			
			player:GetUser():SendToScripts("UpdateLastHospital", self.properties.hospitalId)
		end
	end)
end

function HospitalHealScript:HealMonsters(player)
	if IsServer() then 
		player:GetUser():SendToScripts("DoOnLocal", self:GetEntity(), "HealMonsters", player)
		return
	end
	
	local c = player:FindScript("playerMonstersControllerScript", true)
	
	local monsters = c:GetParty()
	for _, monster in ipairs(monsters) do 
		monster:Heal()
	end
	
	c:Save()

	local sound = player:PlaySound(self.properties.healSound)
	sound:SetPitch(2)
	player:PlayEffect(self.properties.healEffect)
end

return HospitalHealScript
