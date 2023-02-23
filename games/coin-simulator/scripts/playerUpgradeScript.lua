local PlayerUpgradeScript = {}

-- Script properties are defined here
PlayerUpgradeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerUpgradeScript:Init()
	self:GetEntity():GetUser().userUpgradeScript:Assign()
end

return PlayerUpgradeScript
