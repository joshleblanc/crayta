local PlayerWeaponScript = {}

-- Script properties are defined here
PlayerWeaponScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "weapon", type = "entity" },
}

--This function is called on the server when this entity is created
function PlayerWeaponScript:Init()
end

return PlayerWeaponScript
