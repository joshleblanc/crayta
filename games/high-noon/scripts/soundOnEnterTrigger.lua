local SoundOnEnterTrigger = {}

-- Script properties are defined here
SoundOnEnterTrigger.Properties = {
	-- Example property
	{name = "randomSound", type = "soundasset"},
	{name = "highEndNumber", type = "number"}
}

--This function is called on the server when this entity is created
function SoundOnEnterTrigger:Init()
end


function SoundOnEnterTrigger:OnTriggerEnter()
local rand = math.random(1,self.properties.highEndNumber)
	if rand == self.properties.highEndNumber then
		self:GetEntity():PlaySound(self.properties.randomSound)
	end

end
return SoundOnEnterTrigger
