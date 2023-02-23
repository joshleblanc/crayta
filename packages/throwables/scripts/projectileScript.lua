local ProjectileScript = {}

ProjectileScript.Properties = {
	{ name = "lifespan", type = "number", default = 5, },
	{ name = "damageAmount", type = "number", default = 1000, },
	{ name = "damageRadius", type = "number", default = 750, },
	{ name = "damageFalloff", type = "number", default = 1, },
	{ name = "explosionEffect", type = "effectasset", },
	{ name = "explosionSound", type = "soundasset", },
	{ name = "onExplode", type = "event", },
	{ name = "rotationOffset", type = "rotation", },
	{ name = "damageOwner", type = "boolean", default = true, },
	{ name = "launchPlayers", type = "boolean", default = true, },
	{ name = "launchParameters", type ="vector", default = Vector.New(1000, 1000, 1000), visibleIf = function(p) return p.launchPlayers end },
	{ name = "proximityCast", type = "number", default = 200, },
}

function ProjectileScript:Init()
	self.destroyed = false
end

function ProjectileScript:CheckInitialPosition()
	--This fixes that you can shoot into a wall and nothing explodes.
	GetWorld():Raycast(
		self.fromPlayer:GetPosition(),
		self.fromPlayer:GetPosition() + self.fromPlayer:GetForward() * self.properties.proximityCast,
		{ self:GetEntity(), self.fromPlayer },
		function(hitEntity, hitResult)
			if hitEntity then
				self:Explode(hitResult:GetPosition())
			end
		end
	)
end

function ProjectileScript:InitProjectile(rayStart, rayDirection, speed, gunEntity, parent)
	
	self:SetFromPlayer(parent)
	
	-- Check the initial spawning position isn't in a wall using
	-- a raycast from the player, if it is then explode
	self:CheckInitialPosition()
	if self.destroyed then
		return
	end
	
	self:GetEntity():SetVelocity(rayDirection * speed)
	self:GetEntity():SetRotation(Rotation.FromVector(rayDirection) + self.properties.rotationOffset)

	self.lifespanSchedule = self:Schedule(
		function()
			local t = 0
			while t < self.properties.lifespan do
				local dt = Wait()
				GetWorld():Raycast(
					self:GetEntity():GetPosition(),
					self:GetEntity():GetPosition() + self:GetEntity():GetVelocity() * dt,
					{ self:GetEntity(), self.fromPlayer },
					function(hitEntity, hitResult)
						if hitEntity then
							self:Explode(hitResult:GetPosition())
						end
					end
				)
				t = t + dt
			end
			self:Explode(self:GetEntity():GetPosition())
		end
	)
end

function ProjectileScript:Explode(impactPos)
	
	if self.destroyed then 
		return 
	end
	self.destroyed = true

	self:GetEntity().visible = false

	self.properties.onExplode:Send()
	
	--Check radius for player launch effect.
	self:LaunchNearbyPlayers()
	
	if self.lifespanSchedule then
		self:Cancel(self.lifespanSchedule)
	end
	
	GetWorld():ApplyRadialDamage(
		self.properties.damageAmount, 
		impactPos, 
		self.properties.damageRadius, 
		self.properties.damageFalloff, 
		(not self.properties.damageOwner and Entity.IsValid(self.fromPlayer)) and self.fromPlayer or self:GetEntity()
	)
	
	if self.properties.explosionEffect then
		self:GetEntity():PlayEffectAtLocation(impactPos, self:GetEntity():GetRotation(), self.properties.explosionEffect)
	end
	if self.properties.explosionSound then
		self:GetEntity():PlaySoundAtLocation(impactPos, self.properties.explosionSound)
	end
	
	-- destroy a little later after exploding...
	self:Schedule(
		function()
			Wait(3)
			self:GetEntity():Destroy()
		end
	)
	
end

function ProjectileScript:SetFromPlayer(player)
	self.fromPlayer = player
end

function ProjectileScript:LaunchNearbyPlayers()

	if not self.properties.launchPlayers then
		return
	end
	
	for _, user in ipairs(GetWorld():GetUsers()) do
		if user:GetPlayer() then
			-- calculate distance from explosition to player
			local explosionToPlayer = user:GetPlayer():GetPosition() - self:GetEntity():GetPosition()
			local distance = explosionToPlayer:Length()
			if distance <= self.properties.damageRadius then
				-- now get the direction from that vector which is the XY direction
				-- to launch the player
				local direction = explosionToPlayer / distance
				user:GetPlayer():Launch(
					Vector.New(
						direction.x * self.properties.launchParameters.x, 
						direction.y * self.properties.launchParameters.y, 
						self.properties.launchParameters.z
					)
				)
			end
		end
	end
end

return ProjectileScript
