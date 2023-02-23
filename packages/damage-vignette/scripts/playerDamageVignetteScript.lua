local PlayerDamageVignetteScript = {}

-- Script properties are defined here
PlayerDamageVignetteScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerDamageVignetteScript:Init()
	self.widget = self:GetEntity().playerDamageVignetteWidget
end

function PlayerDamageVignetteScript:OnDamage(amt, from, hit)
	self:Schedule(function()
		self.widget.properties.active = true 
		Wait(0.1) -- this is the amount of time it takes to fade in
		self.widget.properties.active = false
	end)
end

return PlayerDamageVignetteScript
