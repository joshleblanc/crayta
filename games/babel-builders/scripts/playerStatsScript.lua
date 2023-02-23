local PlayerStatsScript = {}

-- Script properties are defined here
PlayerStatsScript.Properties = {}


function PlayerStatsScript:Init()
	self:GetEntity():GetUser().userStatsScript:Assign()
end

return PlayerStatsScript
