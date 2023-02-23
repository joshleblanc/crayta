local GhostSettings = {}

-- Script properties are defined here
GhostSettings.Properties = {
	-- Example property
	{name = "worldColorSettings", type = "colorgradingasset"},
	{name = "worldPostProcessingSettings", type = "postprocessasset"},
	{name = "ghostMoveSound", type = "entity"},
	{name = "ghost", type = "entity"},
	{name = "spawnSound", type = "entity"},
	{name = "spawnEffect", type = "entity"},
	{ name = "wispMesh", type = "entity" },
	{ name = "trail2", type = "entity" }
}

function GhostSettings:LocalInit()
	self:GetEntity():GetUser():SendToScripts("Shout", "Get to a portal to respawn!")
	
	self.defaultPostProcess = GetWorld().postProcess
	self.defaultStartTime = GetWorld().startTime
	self.defaultColorGrading = GetWorld().defaultColorGrading
	self.defaultFogStartDistance = GetWorld().fogStartDistance
	self.defaultFogDensity = GetWorld().fogDensity
	self.defaultFogFallout = GetWorld().fogFalloff
	
	
	self:GetEntity():SetInputLocked(true)
	self.properties.ghost.visible = false
	--GetWorld().startTime = .65
	self:GetEntity():GetUser():SendToScripts("DoScreenFade",.5,.5)
	GetWorld().postProcess = self.properties.worldPostProcessingSettings
	GetWorld().colorGrading = self.properties.worldColorSettings
	GetWorld().fogStartDistance = 1500
	GetWorld().fogDensity = 1.364
	GetWorld().fogFalloff = 8.333
	self.movementTracker = 0
	self:Schedule(function()
		Wait(1)
		self.properties.spawnSound.active = true
		self.properties.spawnEffect.active = true
		Wait(.3)
		self.properties.ghost.visible = false
		self:GetEntity():SetInputLocked(false)
	end)
end

function GhostSettings:Disable()
	self:GetEntity():GetUser():SendToScripts("DoScreenFade",.5,.5)
	self:GetEntity():GetUser().inventoryScript:SendToServer("Reset")
	GetWorld().startTime = self.defaultStartTime
	GetWorld().postProcess = self.defaultPostProcess
	GetWorld().colorGrading = self.defaultColorGrading
	GetWorld().fogStartDistance = self.defaultFogStartDistance
	GetWorld().fogDensity = self.defaultFogDensity
	GetWorld().fogFalloff = self.defaultFogFallout
end

function GhostSettings:ShowTrail()
	self.properties.wispMesh.visible = true
	self.properties.trail2.visible = true
end

function GhostSettings:LocalOnButtonPressed(btn)
	print(btn)
	if btn == "forward" or btn == "backward" or btn == "left" or btn == "right" then
		self.movementTracker = self.movementTracker + 1
		if self.movementTracker <= 0 then self.movementTracker = 1 end
	end
end

function GhostSettings:LocalOnButtonReleased(btn)
	if btn == "forward" or btn == "backward"or btn == "left" or btn == "right" then
		self.movementTracker = self.movementTracker - 1
		if self.movementTracker <= 0 then self.movementTracker = 0 end
	end
end

function GhostSettings:LocalOnTick(dt)
	if self.movementTracker > 0 and self.properties.ghostMoveSound.volume < 1 then
		self.properties.ghostMoveSound.volume = self.properties.ghostMoveSound.volume + .005
	elseif self.movementTracker == 0 and self.properties.ghostMoveSound.volume > 0 then
		self.properties.ghostMoveSound.volume = self.properties.ghostMoveSound.volume - .001
	end
	if self.properties.ghostMoveSound.volume < 0 then self.properties.ghostMoveSound.volume = 0 end
end

return GhostSettings
