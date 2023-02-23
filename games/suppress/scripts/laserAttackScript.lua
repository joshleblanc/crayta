local LaserAttackScript = {}

-- Script properties are defined here
LaserAttackScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "trigger", type = "entity" },
	{ name = "effect", type = "entity" },
	{ name = "damage", type = "number", default = 1 },
	{ name = "activeTime", type = "number", default = 5 },
	{ name = "cooldownTime", type = "number", default = 5 },
	{ name = "delay", type = "number", default = 0 },
	{ name = "attackSound", type = "entity" },
	{ name = "attackSoundLoop", type = "entity" }
}

--This function is called on the server when this entity is created
function LaserAttackScript:Init()
	self.attacking = false
	
	self:Schedule(function()
	
		if self.properties.delay > 0 then 
			Wait(self.properties.delay)
		end
		
		while true do 
			self.attacking = true 
			self.properties.attackSound.active = true
			self.properties.attackSoundLoop.active = true
			self.properties.effect.active = true

			Wait(self.properties.activeTime)
			
			self.properties.effect.active = false	
			self.attacking = false
			self.properties.attackSound.active = false
			self.properties.attackSoundLoop.active = false
			
			Wait(self.properties.cooldownTime)
		end
	end)
	
	self:Schedule(function()
		while true do 
			if self.attacking then 
				local contents = self.properties.trigger.triggerTrackerScript:Contents()
				for _, c in ipairs(contents) do 
					self:Damage(c)
				end
			end
			
			Wait(0.1)
		end
	end)
end

function LaserAttackScript:Damage(entity)
	local pos = self:GetEntity():GetPosition()
	entity:ApplyDamage(self.properties.damage, (pos - entity:GetPosition()):Normalize(), self:GetEntity())
end

return LaserAttackScript
