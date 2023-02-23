local PlayerStatEffectsScript = {}

-- Script properties are defined here
PlayerStatEffectsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerStatEffectsScript:Init()
	self:Schedule(function()
		self:GetEntity():GetUser().saveDataScript:WaitForData()
		
		self:UpdatePlayerEffects()
	end)
end

function PlayerStatEffectsScript:UpdatePlayerEffects()
	local stats = self:GetEntity():GetUser().userStatsScript:GetStats()

		for k, v in pairs(stats) do 
			if k == "health" then 
				self:GetEntity().healthScript.properties.maxHp = (v:Level() + 1) * 10
				self:GetEntity().healthScript.properties.hp = (v:Level() + 1) * 10
			end
			if k == "stamina" then 
				self:GetEntity().SPCore:UpdateStats({ (v:Level() + 1) * 10, nil, nil }, false)
			end
			if k == "fire-rate" then 
				self:GetEntity().playerWeaponScript.properties.weapon.horizontalLineAttackScript.properties.cooldown = 1 - ((v:Level() + 1) / 100)
			end
		end
end

return PlayerStatEffectsScript
