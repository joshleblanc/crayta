local UserDebugKillScript = {}

-- Script properties are defined here
UserDebugKillScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "active", type = "boolean", deafult = false }
}

--This function is called on the server when this entity is created
function UserDebugKillScript:Init()
	assert(not self.properties.active, "User Debug Kill Script is active")
end

function UserDebugKillScript:OnButtonPressed(btn)
	if btn == "interact" and self.properties.active then 
		self:GetEntity():GetPlayer():ApplyDamage(1000, Vector.Zero, self:GetEntity())
	end
end

return UserDebugKillScript
