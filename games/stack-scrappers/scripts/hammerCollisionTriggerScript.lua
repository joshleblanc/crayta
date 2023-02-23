local HammerCollisionTriggerScript = {}

-- Script properties are defined here
HammerCollisionTriggerScript.Properties = {
	-- Example property
	{name = "smashPoint", type = "entity"},
}

--This function is called on the server when this entity is created
function HammerCollisionTriggerScript:Init()
end

function HammerCollisionTriggerScript:OnTriggerEnter(other)
print(other)
	if other == self.properties.smashPoint then
		print("SMASH")
	end
end

return HammerCollisionTriggerScript
