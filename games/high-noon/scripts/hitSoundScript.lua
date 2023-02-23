local HitSoundScript = {}

-- Script properties are defined here
HitSoundScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "sounds", type = "soundasset", container = "array" }
}

function HitSoundScript:EntityHit(hit,user)
	self:GetEntity():PlaySound(self.properties.sounds[math.random(1, #self.properties.sounds)])
end


return HitSoundScript
