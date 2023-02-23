local PlayerReviveScript = {}

-- Script properties are defined here
PlayerReviveScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerReviveScript:Init()
end

function PlayerReviveScript:RevivePlayer()
	if not IsServer() then 
		self:SendToServer("RevivePlayer")
		return
	end
	
	self:GetEntity():GetUser():SendToScripts("UseDb", "default", function(db)
		local config = db:FindOne({})
		local hospitalId = config.lastHospital
		
		local c = GetWorld():FindScript("hospitalControllerScript")
		
		local spawnPoint = c:FindSpawn(hospitalId)
		self:Schedule(function()
			self:GetEntity():GetUser():SendToLocal("DoScreenFade", 1, 1)
			Wait(1)
			spawnPoint.properties.spawnLocation:GetParent():FindScript("hospitalHealScript", true):HealMonsters(self:GetEntity())
			self:GetEntity():SetPosition(spawnPoint.properties.spawnLocation:GetPosition())
		end)
		
	end)
end

return PlayerReviveScript
