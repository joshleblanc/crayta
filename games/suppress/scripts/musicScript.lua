local MusicScript = {}

-- Script properties are defined here
MusicScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "music", type = "soundasset" }
}

--This function is called on the server when this entity is created
function MusicScript:LocalInit()
	self:GetEntity():PlaySound2D(self.properties.music)
end

return MusicScript
