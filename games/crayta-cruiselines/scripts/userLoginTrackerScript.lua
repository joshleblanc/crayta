local UserLoginTrackerScript = {}

-- Script properties are defined here
UserLoginTrackerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserLoginTrackerScript:Init()
	self:GetEntity():SetLeaderboardValue("last-played", GetWorld():GetUTCTime())
	self:GetEntity():AddToLeaderboardValue("most-played", 1)
end

return UserLoginTrackerScript
