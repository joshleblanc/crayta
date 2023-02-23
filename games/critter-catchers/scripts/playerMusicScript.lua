local PlayerMusicScript = {}

-- Script properties are defined here
PlayerMusicScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "world", type = "soundasset" },
	{ name = "battle", type = "soundasset" },
}

--This function is called on the server when this entity is created
function PlayerMusicScript:Init()
end

function PlayerMusicScript:LocalInit()
	self:PlayMusic("world")
end

function PlayerMusicScript:PlayMusic(what)
	self:GetEntity():PlaySound2D(self.properties[what], 1, "music")
end

return PlayerMusicScript
