local BodyDropScript = {}

-- Script properties are defined here
BodyDropScript.Properties = {
	-- Example property
	{name = "bodyDropSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function BodyDropScript:Init()
end

function BodyDropScript:OnTriggerEnter(other)
	if other:IsA(Character) and other:IsAlive() == false then
		other:PlaySound(self.properties.bodyDropSound)
		print("You ded")
	end
end

return BodyDropScript
