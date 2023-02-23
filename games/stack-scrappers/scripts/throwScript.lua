local ThrowScript = {}

-- Script properties are defined here
ThrowScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "template", type = "template" }
}

--This function is called on the server when this entity is created
function ThrowScript:Init()
end

function ThrowScript:OnTick()
	local g = GetWorld():Spawn(self.properties.template, self:GetEntity())
	local script = g:FindScript("pickupSpawnerScript", true)
	script:ShowPickup()
	script.properties.singlePickup = true
	g:SendToScripts("Fly")
end

return ThrowScript
