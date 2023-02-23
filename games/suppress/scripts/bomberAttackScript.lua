local BomberAttackScript = {}

-- Script properties are defined here
BomberAttackScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "output", type = "entity" },
	{ name = "orb", type = "template" },
	{ name = "effect", type = "effectasset" },
	{ name = "fireSound", type = "soundasset" },
	{ name = "cooldownTime", type = "number", default = 5 },
	{ name = "delay", type = "number", default = 0 },
	{ name = "chargeEffect", type = "entity" },
	{ name = "chargeTime", type = "number", default = 1 },
	{ name = "objectPool", type = "entity" },
}

--This function is called on the server when this entity is created
function BomberAttackScript:Init()
	self.objectPool = self.properties.objectPool
	
	self.attacking = false
	
	self:Schedule(function()
	
		if self.properties.delay > 0 then 
			Wait(self.properties.delay)
		end
		
		while true do 
			self.attacking = true 
			
			self.properties.chargeEffect.active = true
			Wait(self.properties.chargeTime)
			self.properties.chargeEffect.active = false
			
			
			local outputPos = self.properties.output:GetPosition()
			self:GetEntity():PlayEffectAtLocation(outputPos, self.properties.output:GetRotation(), self.properties.effect)
			local dir = self.properties.output:GetForward()
			local rot = Rotation.FromVector(dir)
			
			local orb = self.objectPool.objectPoolScript:GetAvailableObj(self.properties.orb)
			orb:SetPosition(outputPos)
			orb:SetRotation(rot)
			--local orb = GetWorld():Spawn(self.properties.orb, outputPos, rot)
			
			orb:SendToScripts("SetOwner", self:GetEntity())
			
			orb:SendToScripts("SetVelocity", dir * 1000)

			
			self:GetEntity():PlaySound(self.properties.fireSound)
			
			self.attacking = false
			
			Wait(self.properties.cooldownTime)			
		end
	end)
end

return BomberAttackScript
