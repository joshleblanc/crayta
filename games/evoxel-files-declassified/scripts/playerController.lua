local PlayerController = {}

-- Script properties are defined here
PlayerController.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "lobbySpawn", type = "entity" },
	{ name = "camera", type = "entity" },
	{ name = "playing", type = "boolean", editable = false },
	{ name = "arenaMusic", type = "soundasset" },
}

function PlayerController:OnButtonPressed() 
	--self:GetEntity():GetUser():SetCamera(self.properties.camera)
end

function PlayerController:Start()
	if self.properties.playing then 
		return
	end
	
	if not self:GetEntity():IsLocal() then
		self:GetEntity():SendToLocal("Start")
		self.properties.playing = true
		return
	end

	if not self.arenaMusicHandle then
		self.arenaMusicHandle = self:GetEntity():PlaySound(self.properties.arenaMusic)
	end

	self:GetCamera().cameraType = 2
	self:GetCamera().cameraCollisionEnabled = false
	self:GetEntity():GetUser().showDefaultCrosshair = false
	--self:GetEntity().canJump = false
	self:GetEntity().canSprint = false
	self:GetEntity().speedMultiplier = 2
end

function PlayerController:AddScore(score)
	if IsServer() then
		self:SendToLocal("AddScore", score)
		return
	end
	self:GetEntity():FindScript("timer"):SendToScript("AddScore", score)
end


function PlayerController:GetCamera()
	return self:GetEntity():GetUser():GetCamera()
end

function PlayerController:OnTick() 
	if self:GetEntity():GetPosition().z < -1000 then
		self:GetEntity():GetUser().userController:Kill()
	end
	if self:GetEntity():GetPosition().z > 1300 then
		self:GetEntity():GetUser().userController:Kill()
	end
	
	if self.properties.playing and self:GetEntity():GetPosition().z > 200 then
		self:GetEntity():GetUser().userController:Kill()
	end
end

return PlayerController
