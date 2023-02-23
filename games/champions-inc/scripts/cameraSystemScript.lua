local CameraSystemScript = {}

-- Script properties are defined here
CameraSystemScript.Properties = {
	-- Example property
	{name = "camerasLocator", type = "entity"},
}

--This function is called on the server when this entity is created
function CameraSystemScript:Init()
end

function CameraSystemScript:CamerasActivated(player)
	if player:GetUser().userCameraScript.properties.inCamera == false then
		local cameraList = self.properties.camerasLocator:GetChildren()
		player:GetUser():SendToScripts("CameraList", cameraList)
		player:GetUser():SendToScripts("InCamera", true)
	end
end


return CameraSystemScript
