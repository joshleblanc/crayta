local RandomBrokenGearScript = {}

-- Script properties are defined here
RandomBrokenGearScript.Properties = {
	-- Example property
	{name = "gear1", type = "meshasset"},
	{name = "gear2", type = "meshasset"},
	{name = "gear3", type = "meshasset"},
	{name = "gear4", type = "meshasset"},
}

--This function is called on the server when this entity is created
function RandomBrokenGearScript:Init()
	local choices = {self.properties.gear1, self.properties.gear2, self.properties.gear3, self.properties.gear4}
	local rand = math.random(#choices)
	self:GetEntity().mesh = choices[rand]
	self:GetEntity().physicsEnabled = true
	self:GetEntity().gravityEnabled = true
	
end

return RandomBrokenGearScript
