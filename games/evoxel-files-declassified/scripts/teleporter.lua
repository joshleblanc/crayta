local Teleporter = {}

-- Script properties are defined here
Teleporter.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "sound", type = "soundasset" }
}

--This function is called on the server when this entity is created
function Teleporter:Init()
end

function OnCollision()
	self:GetEntity():PlaySound(self.properties.sound)
end

return Teleporter
