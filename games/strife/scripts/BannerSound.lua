local BannerSound = {}

-- Script properties are defined here
BannerSound.Properties = {
	-- Example property
	{name = "bannerSound", type = "soundasset", },
	{name = "bannerSound2", type = "soundasset", },
}

--This function is called on the server when this entity is created
function BannerSound:Init()
	self:Schedule(function()
		self:GetEntity():PlaySound(self.properties.bannerSound)
		self:GetEntity():PlaySound(self.properties.bannerSound2)
	end)
	
end


function BannerSound:Play()
	self:GetEntity():PlaySound(self.properties.bannerSound)
end

return BannerSound
