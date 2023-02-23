local PlayerCameraFix = {}

-- Script properties are defined here
PlayerCameraFix.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerCameraFix:Init()
	local loc = self:GetEntity():GetUser().userLocationScript.properties.locationEntity
	if loc and loc.roomScript then 
		self:GetEntity().cameraYaw = loc.roomScript.properties.cameraRotation
	end
end

return PlayerCameraFix
