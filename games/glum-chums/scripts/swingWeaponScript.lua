local SwingWeaponScript = {}

-- Script properties are defined here
SwingWeaponScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function SwingWeaponScript:Init()
end


function SwingWeaponScript:OnButtonPressed(btn)
	if btn == "primary" then 
		self:GetEntity():SendToScripts("SwingWeapon")
	end
end
return SwingWeaponScript
