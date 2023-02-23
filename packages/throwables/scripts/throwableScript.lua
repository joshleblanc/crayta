local ThrowableScript = {}

ThrowableScript.Properties = {
	{ name = "useSelfAsProjectile", type = "boolean", default = true },
	{ name = "projectileTemplate", type = "template", visibleIf = function(p) return not p.useSelfAsProjectile end },
	{ name = "throwDelay", type = "number", default = 1 },
	{ name = "velocity", type = "number", default = 2500 }
}

function ThrowableScript:Init()
	self.recharging = false
end

function ThrowableScript:OnButtonPressed(btn)
	if btn == "primary" then 
		if not self.recharging then 
			self:Throw()
		end
	end
end

function ThrowableScript:Recharge()
	self.recharging = true 
	self:Schedule(function()
		Wait(self.properties.throwDelay)
		self.recharging = false
	end)
end

function ThrowableScript:GetProjectileTemplate()
	if self.properties.useSelfAsProjectile then 
		return self:GetEntity():GetTemplate()
	else 
		return self.properties.projectileTemplate
	end
end

function ThrowableScript:Throw()
	self:Recharge()
	
	local parent = self:GetEntity():GetParent()
	
	parent:PlayAction("Melee")
	
	self:Schedule(function()
		Wait(1/8) -- The melee animation is at its highest point after an eighth of a second
		
		local start = self:GetEntity():GetPosition()
		local endPos = parent:GetLookAtPos()
		local dir = (endPos - start):Normalize()
		
		local projectile = GetWorld():Spawn(self:GetProjectileTemplate(), start, Rotation.Zero)
		
		projectile.physicsEnabled = true
		projectile:SendToScripts("SetVisibleAndCollision", true, false) -- If the projectile is a pickup, we don't want it to be picked up in the air
		projectile:SendToScripts("InitProjectile", start, dir, self.properties.velocity, self:GetEntity(), parent)
		
		parent:GetUser():SendToScripts("RemoveTemplate", self:GetEntity():GetTemplate(), 1)
	end)
	
	
end

return ThrowableScript
