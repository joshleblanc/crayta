local BounceScript = {}

-- Script properties are defined here
BounceScript.Properties = {
	-- Example property
	{name = "bounceSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function BounceScript:Init()
end

function BounceScript:OnTriggerEnter(player)
	self:Schedule(function()
		player:PlaySound(self.properties.bounceSound)
		player:SetVelocity(Vector.Zero)
		Wait()
		player:Launch(Vector.New(0,0,1200))
	end)
end

return BounceScript
