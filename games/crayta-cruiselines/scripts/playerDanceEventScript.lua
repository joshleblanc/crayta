local PlayerDanceEventScript = {}

-- Script properties are defined here
PlayerDanceEventScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerDanceEventScript:Init()
end

function PlayerDanceEventScript:SpinCamera(camera, delay)
	self.cameraHandle = self:Schedule(function()
		--Wait(delay)
		
		local rotationTime = 10
		print("Rotating")
		camera:AlterRotation(Rotation.Zero, Rotation.New(0, 359, 0), rotationTime)
		Wait(rotationTime)
		self:SendToServer("FinishSpin")
	end)
end

function PlayerDanceEventScript:FinishSpin()
	print("Finishing")
	self:GetEntity():GetUser():SetCamera(self:GetEntity(), 1.5)
end

function PlayerDanceEventScript:Start(callback)
	self.participationHandle = self:Schedule(function()
		Wait(3)
		callback()
	end)
end

function PlayerDanceEventScript:LocalCancelParticipation()
	if self.cameraHandle then
		print("Cancelling camera spin")
		self:SendToServer("FinishSpin")
		self:Cancel(self.cameraHandle)
		self.cameraHandle = nil
	end
end

function PlayerDanceEventScript:CancelParticipation()
	if self.participationHandle then
		print("Cancelling participation")
		self:FinishSpin()
		self:Cancel(self.participationHandle)
		self.participationHandle = nil
	end
	self:SendToLocal("LocalCancelParticipation")
end

return PlayerDanceEventScript
