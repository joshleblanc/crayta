local PlayerFallDamageScript = {}

PlayerFallDamageScript.Properties = {
	{ name = "minimumVelocity", type = "number", default = 1500 },
	{ name = "damageMultiplier", type = "number", default = 1 },
	{ name = "fallDamageSound", type = "soundasset" },
	{ name = "fallDamageGrunt", type = "soundasset" },
	{ name = "dirtEffect", type = "effectasset" },
	{ name = "fallDamageShake", type = "camerashakeasset" },
	{ name = "minimumDamageForSound", type = "number", default = 400 }
}

function PlayerFallDamageScript:Init()
	self.preventDamage = false
end

function PlayerFallDamageScript:OnTick()
	local vel = self:GetEntity():GetVelocity()

	if self.lastVel then 
		local diff = vel.z - self.lastVel.z
		
		if diff > self.properties.minimumVelocity then
			
			if not self.preventDamage then 
			
				local damage = diff - self.properties.minimumVelocity
				local damageMultiplier = self.properties.damageMultiplier
				if self:GetEntity():GetUser().fallDamageOverridesScript then 
					damageMultiplier = self:GetEntity():GetUser().fallDamageOverridesScript.properties.damageMultiplier
				end
				damage = damage * damageMultiplier

				local entity = self:GetEntity()
				
				
				entity:ApplyDamage(damage, vel:Normalize(), self.collisionEntity)
				entity:PlaySound(self.properties.fallDamageGrunt)
				
				if damage > self.properties.minimumDamageForSound then
					entity:PlaySound(self.properties.fallDamageSound)
				end
				
				local pos = entity:GetPosition() + Vector.New(0,0,-100)
				entity:PlayEffectAtLocation(pos, Rotation.Zero, self.properties.dirtEffect)
				entity:GetUser():PlayCameraShakeEffect(self.properties.fallDamageShake,.3)
			end
			
			
			self.preventDamage = false 
		end
	end
	
	self.lastVel = vel
end

function PlayerFallDamageScript:OnCollision(entity)
	self.collisionEntity = entity
end

function PlayerFallDamageScript:WillTakeDamage()
	return self:GetEntity():GetVelocity().z < -self.properties.minimumVelocity
end

function PlayerFallDamageScript:AllowDamage()
	self:CancelPause()
	
	self.preventDamage = false
end

function PlayerFallDamageScript:CancelPause()
	if self.pauseHandle then 
		self:Cancel(self.pauseHandle)
	end
end

function PlayerFallDamageScript:PauseDamage(time)
	self:CancelPause()
	
	self.pauseHandle = self:Schedule(function()
		self.preventDamage = true
		Wait(time)
		self.preventDamage = false
	end)
end

function PlayerFallDamageScript:PreventDamage(force)
	if self:WillTakeDamage() or force then 
		self:CancelPause()
		self.preventDamage = true 
	end
end

return PlayerFallDamageScript
