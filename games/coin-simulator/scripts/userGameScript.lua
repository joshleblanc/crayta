local UserGameScript = {}

-- Script properties are defined here
UserGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "playerTemplate", type = "template" },
	{ name = "startPosition", type = "entity" },
	{ name = "playing", type = "boolean", editable = false, default = false },
	{ name = "gameController", type = "entity" }
}

--This function is called on the server when this entity is created
function UserGameScript:Init()
end

function UserGameScript:LocalInit()
	self.widget = self:GetEntity().userGameWidget
end

function UserGameScript:AddRunPoints(points)
	self.runPoints = self.runPoints + points
end

function UserGameScript:AddRunCoins(coins)
	self.runCoins = self.runCoins + coins
end

function UserGameScript:Start()
	if IsServer() then 
		self.runPoints = 0
		self.runCoins = 0
		self.properties.playing = true
		self:SendToLocal("Start")
		return
	end	

	self:Schedule(function()
		Wait(2)
		self.widget:Show()
		for i=0,10 do
			local num = 10 - i
			self:GetEntity().announcerScript:Say(num)
			self.widget.js.data.num = num
			Wait(1)
		end
		
		self.widget:Hide()
		
		self:Respawn()
	end)
end

function UserGameScript:Respawn()
	if not IsServer() then
		self:SendToServer("Respawn")
		return
	end
	
	self.properties.playing = false
	self:GetEntity():SetLeaderboardValue("best-round", self.runPoints)
	self:GetEntity():AddToLeaderboardValue("rounds-played", 1)
	self:GetEntity():SendXPEvent("complete-round")
	
	local me = self:GetEntity()
	GetWorld():ForEachUser(function(user) 
		if user == me then
			user:SendToScripts("AddNotification", FormatString("You picked up {1} coins, scoring {2} points", self.runCoins, self.runPoints))
		else
			user:SendToScripts("AddNotification", FormatString("{1} picked up {2} coins, scoring {3} points", tostring(user:GetUsername()), self.runCoins, self.runPoints))
		end
	end)
	
	self.runPoints = 0
	self.runCoins = 0
	
	self:GetEntity():DespawnPlayerWithEffect(function() 
		self:GetEntity():SpawnPlayerWithEffect(self.properties.playerTemplate)
		self.properties.gameController:SendToScripts("TryReset")
	end)
end

function UserGameScript:PlaySound(sound)
	if IsServer() then
		self:SendToLocal("PlaySound", sound)
		return
	end
	
	self:GetEntity():PlaySound2D(sound)
end

return UserGameScript
