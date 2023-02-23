local PickupScript = {}

-- Script properties are defined here
PickupScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "sound", type = "soundasset" }
}

function PickupScript:HandlePickup(player)
	player:GetUser():AddToLeaderboardValue("coins-collected", 1)
	player:GetUser():SendXPEvent("collect-coins")
	
	
	local points = math.floor(1 + (self:GetEntity():GetPosition().z / 250))
	
	player:GetUser().userGameScript:AddRunPoints(points)
	player:GetUser().userGameScript:AddRunCoins(1)
	
	player:GetUser().userPointsScript:Add(points)
	player:GetUser().userGameScript:PlaySound(self.properties.sound)
	self:GetEntity().visible = false
	local children = self:GetEntity():GetChildren()
	for _, child in ipairs(children) do
		child.active = false
	end
	
	self:Schedule(function()
		Wait(10)
		self:GetEntity().visible = true
		local children = self:GetEntity():GetChildren()
		for _, child in ipairs(children) do
			child.active = true
		end
	end)
end

return PickupScript
