local AnnouncerScript = {}

AnnouncerScript.Properties = {
	{ name = "go", type = "soundasset" },
	{ name = "players left", type = "soundasset" },
	{ name = "0", type = "soundasset" },
	{ name = "1", type = "soundasset" },
	{ name = "2", type = "soundasset" },
	{ name = "3", type = "soundasset" },
	{ name = "4", type = "soundasset" },
	{ name = "5", type = "soundasset" },
	{ name = "6", type = "soundasset" },
	{ name = "7", type = "soundasset" },
	{ name = "8", type = "soundasset" },
	{ name = "9", type = "soundasset" },
	{ name = "10", type = "soundasset" },
	{ name = "11", type = "soundasset" },
	{ name = "12", type = "soundasset" },
	{ name = "13", type = "soundasset" },
	{ name = "14", type = "soundasset" },
	{ name = "15", type = "soundasset" },
	{ name = "16", type = "soundasset" },
	{ name = "321", type = "soundasset" },
	{ name = "power up", type = "soundasset" },
	{ name = "round over", type = "soundasset" },
	{ name = "uhoh", type = "soundasset" },
	{ name = "vote end", type = "soundasset" },
	{ name = "vote start", type = "soundasset" },
	{ name = "welcome contestants", type = "soundasset" },
	{ name = "you win", type = "soundasset" },
	{ name = "game over", type = "soundasset" }
}


------------------------------------------------------------------------------
-- https://github.com/tbastos/lift/blob/master/lift/string.lua
------------------------------------------------------------------------------
local str_upper = string.upper
local str_gsub = string.gsub

-- Returns the Capitalized form of a string
local function capitalize(str)
  return (str_gsub(str, '^%l', str_upper))
end

-- Returns the UpperCamelCase form of a string
local function classify(str)
  return (str_gsub(str, '%W*(%w+)', capitalize))
end
------------------------------------------------------------------------------
-- https://github.com/tbastos/lift/blob/master/lift/string.lua
------------------------------------------------------------------------------

for k,v in ipairs(AnnouncerScript.Properties) do 
	local key = classify(v.name)

	AnnouncerScript["Say" .. key] = function(self)
		self:Say(v.name)
	end
	
	AnnouncerScript["ClientSay" .. key] = function(self)
		self:ClientSay(v.name)
	end
end

function AnnouncerScript:ShutUp()
	if self.soundHandle then 
		self:GetEntity():StopSound(self.soundHandle)
	end
end

function AnnouncerScript:ClientSay(what)
	if IsServer() then
		self:SendToLocal("Say", what)
	end
end

function AnnouncerScript:Say(what)
	local key = string.lower(what)
	
	self.soundHandle = self:GetEntity():PlaySound2D(self.properties[key])
end

return AnnouncerScript
