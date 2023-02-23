local NPCDancerScript = {}

-- Script properties are defined here
NPCDancerScript.Properties = {
	-- Example property
	{name = "emote1", type = "emoteasset"},
	{name = "danceLocator", type = "entity"},
}

--This function is called on the server when this entity is created
function NPCDancerScript:Init()
	self:Schedule(function()
		Wait(math.random(3,20))
		while true do
			self:GetEntity():PlayEmote(self.properties.emote1)
			Wait(30)
		end
	end)
	
end

function NPCDancerScript:OnTick(dt)
local z = self.properties.danceLocator:GetPosition()
z = z.z
	if (self:GetEntity():GetPosition()).z < z then
		self:GetEntity():SetRotation(self:GetEntity():GetRotation() + Rotation.New(0,23,0))
		self:GetEntity():Launch(self:GetEntity():GetUp():Normalize() * 105)	
	end
end




return NPCDancerScript
