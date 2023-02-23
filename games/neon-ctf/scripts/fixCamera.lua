local FixCamera = {}

function FixCamera:Game()
	self:GetEntity().cameraYaw = -180
end

function FixCamera:Lobby()
	self:GetEntity().cameraYaw = 0
end

return FixCamera
