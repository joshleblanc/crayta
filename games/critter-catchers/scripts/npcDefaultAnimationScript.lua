local NpcDefaultAnimationScript = {}

-- Script properties are defined here
NpcDefaultAnimationScript.Properties = {
	-- Example property
	{name = "defaultEmote", type = "emoteasset"},
}

--This function is called on the server when this entity is created
function NpcDefaultAnimationScript:Init()
	self:Schedule(function()
		Wait(5)
		print("waited 5")
		self:GetEntity():PlayEmote(self.properties.defaultEmote)
	end)
end

return NpcDefaultAnimationScript
