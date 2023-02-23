local UserController = {}

-- Script properties are defined here
UserController.Properties = {
	{ name = "defaultPostProcess", type = "postprocessasset" },
	{ name = "lightsToTurnOff", type = "entity", container = "array" },
	{ name = "deathCam", type = "entity" }
}

function UserController:End()
	if not self:GetEntity():IsLocal() then
		self:GetEntity():SendToLocal("End")
		return
	end
	
	self:GetEntity().notificationWidget.visible = true
	self:GetEntity().showDefaultCrosshair = true
	self:SetPostProcess(self.properties.defaultPostProcess)
	self.dead = false
end

function UserController:Start()
	if IsServer() then 
		self:SendToLocal("Start")
		return
	end
	
	self:GetEntity().notificationWidget.visible = false
end

function UserController:Kill()
	local user = self:GetEntity()
	local player = user:GetPlayer()
	local template = player:GetTemplate()
	
	player:SetVelocity(Vector.New(0,0,0))
	player:SetAlive(false)
	
	self:SendToLocal("LocalKill")
end

function UserController:LocalKill()
	if self.dead then return end 
	self.dead = true
	local user = self:GetEntity()
	local player = user:GetPlayer()
	local template = player:GetTemplate()
	self:Schedule(function() 
	
		player.timer:Stop(user)

		Wait(3)
		
		player.timer:Hide(user)
		player.dialogScript:End()
		
		Wait(1)
		
		self:SendToServer("Respawn")
	end)
end

function UserController:Respawn()
	local user = self:GetEntity()
	user:SetCamera(self.properties.deathCam, 1)
	user:DespawnPlayerWithEffect(function() 
		user:SendToLocal("End")
		user:SpawnPlayerWithEffect(template) 	
		self.properties.playing = false
	end)
end

function UserController:SetPostProcess(postProcess)
	if IsServer() then
		self:SendToLocal("SetPostProcess", postProcess)
		return
	end
	if GetWorld().postProcess == postProcess then
		GetWorld().postProcess = self.properties.defaultPostProcess
	else
		GetWorld().postProcess = postProcess
	end
	
	if GetWorld().postProcess == self.properties.defaultPostProcess then
		GetWorld().sunIntensity = 0
		GetWorld().heightFogDensity = 3.3
		for i = 1,#self.properties.lightsToTurnOff,1 do
			self.properties.lightsToTurnOff[i].intensity = 1000
		end
	else
		GetWorld().sunIntensity = 8.2
		GetWorld().heightFogDensity = 0
		for i = 1,#self.properties.lightsToTurnOff,1 do
			self.properties.lightsToTurnOff[i].intensity = 0
		end
	end
end


return UserController
