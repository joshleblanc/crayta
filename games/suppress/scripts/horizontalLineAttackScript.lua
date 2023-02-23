local HorizontalLineAttackScript = {}

-- Script properties are defined here
HorizontalLineAttackScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "orb", type = "template" },
	{ name = "attacking", type = "boolean", default = false, editable = false },
	{ name = "numberOfShots", type = "number", default = 7 },
	{ name = "cooldown", type = "number", default = 3 },
	{ name = "chargeTime", type = "number", default = 1 },
	{ name = "chargingEffect", type = "entity" },
	{ name = "chargingSound", type = "soundasset" },
	{ name = "fireSound", type = "soundasset" },
	{ name = "fireEffect", type = "effectasset" },
	{ name = "velocity", type = "number", default = 2000 },
	{ name = "objectPool", type = "entity" },
	{ name = "playerSpecific", type = "boolean", default = false },
	{ name = "muzzleLoc", type = "entity",},
}

function HorizontalLineAttackScript:Init()
	self.objectPool = self.properties.objectPool
end

function HorizontalLineAttackScript:Attack(user, from)
	self.properties.attacking = true
	
	local player
	if user and user:IsA(User) then 
		player = user:GetPlayer()
	else
		player = user
	end
	
	self:Schedule(function()	
		self:GetEntity():PlaySound(self.properties.chargingSound)
		if self.properties.chargingEffect then 
			self.properties.chargingEffect.active = true
		end
		
		Wait(self.properties.chargeTime)
		
		if self.properties.chargingEffect then 
			self.properties.chargingEffect.active = false
		end
		
		local outputPos = self:GetEntity():FindScriptProperty("output"):GetPosition()
		for i=1,self.properties.numberOfShots do 
			if Entity.IsValid(player) then 
				local target = player:GetPosition()
				
				if player:IsA(Character) then  -- aim center mass
					target.x = (target.x - (100 * i)) + 350
				end
				
				local dir = (outputPos - target):Normalize()
				local rot = Rotation.FromVector(dir)
				
				local orb = self.objectPool.objectPoolScript:GetAvailableObj(self.properties.orb)
				orb:SetPosition(outputPos, rot)
				--local orb = GetWorld():Spawn(self.properties.orb, outputPos, rot)
				
				orb:SendToScripts("SetOwner", from)	
				orb:SendToScripts("SetVelocity", dir * -self.properties.velocity)
				
				self:GetEntity():PlaySound(self.properties.fireSound)
				
				
				Wait()
			end
		end
		
		Wait(self.properties.cooldown)
		self.properties.attacking = false
	end)
end

return HorizontalLineAttackScript
