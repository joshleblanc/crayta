local UserFishingPowerScript = {}

-- Script properties are defined here
UserFishingPowerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserFishingPowerScript:Init()
end

function UserFishingPowerScript:GetFishingPower()
	local fishingPower = 0
	
	self:GetEntity().userPosessionsScript:ForEachPosession(function(p)
		fishingPower = fishingPower + p:GetFishingPower()
	end)
	
	return fishingPower
end

return UserFishingPowerScript
