local RecoilDamageScript = {}

-- Script properties are defined here
RecoilDamageScript.Properties = {
	{ name = "moveId", type = "string" },
	{ name = "chance", type = "number", default = 1 },
	{ name = "damagePercent", type = "number", default = 0 },
}

--This function is called on the server when this entity is created
function RecoilDamageScript:Init()
end

function RecoilDamageScript:Apply(battle)
	if battle.state.move.properties.id ~= self.properties.moveId then return end
	
	if math.random() < self.properties.chance then 
		local damage = battle.state.damage * self.properties.damagePercent
	
		table.insert(battle.state.messages, FormatString("{1} is hit with recoil", battle.state.from.properties.name))
		battle.state.from:ApplyDamage(damage)
	end
end

return RecoilDamageScript
