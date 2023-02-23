local UserCameraScript = {}

-- Script properties are defined here
UserCameraScript.Properties = {
	-- Example property
	{name = "inCamera", type = "boolean", default = false},
}

--This function is called on the server when this entity is created
function UserCameraScript:Init()
	self.cameraList = {}
	self.camNum = 0
end

function UserCameraScript:InCamera(bool)
	self.properties.inCamera = bool
end

function UserCameraScript:OnButtonPressed(btn)
	if btn ~= "interact" then return end 
	if not self.properties.inCamera then return end 
	
	if self.camNum < #self.cameraList then
		self.camNum = self.camNum + 1
		self:SetCameraTo(self.cameraList[self.camNum])
	elseif self.camNum >= #self.cameraList then
		self:GetEntity():SetCamera(self:GetEntity():GetPlayer())
		self.camNum = 0
		self.cameraList = {}
		
		self:Schedule(function()
			Wait()
			self:InCamera(false)
		end)
		
	end
end

function UserCameraScript:CameraList(list)
	self.cameraList = list
	self:SetCameraTo(self.cameraList[1])
	self.camNum = 1
end

function UserCameraScript:SetCameraTo(cam)
	self:GetEntity():SetCamera(cam)
end


return UserCameraScript
