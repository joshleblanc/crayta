local MusicControllerScript = {}

-- Script properties are defined here
MusicControllerScript.Properties = {
	-- Example property
	--{name = "HighNoonMusic", type = "soundasset"},
	--{name = "HighNoonNotActiveMusic", type = "soundasset"},
	{name = "highNoonStart", type = "soundasset"},
	{name = "highNoonEnd", type = "soundasset"},
	{name = "highNoonMusicArray",type = "entity", container = "array"},
	{name = "HighNoonNotActiveMusicArray",type = "entity", container = "array"}
}

--This function is called on the server when this entity is created
function MusicControllerScript:Init()
	self:SetDefaults(self.properties.highNoonMusicArray)
	self:SetDefaults(self.properties.HighNoonNotActiveMusicArray)
end

function MusicControllerScript:SetDefaults(arr)
	for i=1,#arr do
		local v = arr[i]
		v.volume = 0.3
		v.pitch = 0.8
		v.active = false
	end
end

function MusicControllerScript:TurnOffEverything()
	self:TurnOffArray(self.properties.HighNoonNotActiveMusicArray)
	self:TurnOffArray(self.properties.highNoonMusicArray)
end

function MusicControllerScript:TurnOffArray(arr)
	for i=1,#arr do
		arr[i].active = false
	end
end

function MusicControllerScript:HighNoonActive()
self:Schedule(
	function()
		Wait(1)
		self:GetEntity():PlaySound2D(self.properties.highNoonStart)
		Wait(1)
		self:TurnOffEverything()
		local rand = math.random(1,#self.properties.highNoonMusicArray)
		self.properties.highNoonMusicArray[rand].active = true
	
	end)
end

function MusicControllerScript:HighNoonNotActive()
self:Schedule(
		function()
		Wait(1)
		self:GetEntity():PlaySound2D(self.properties.highNoonEnd)
		Wait(1)
		
		self:TurnOffEverything()
		local rand = math.random(1,#self.properties.HighNoonNotActiveMusicArray)
		self.properties.HighNoonNotActiveMusicArray[rand].active = true
	end)
end



return MusicControllerScript
