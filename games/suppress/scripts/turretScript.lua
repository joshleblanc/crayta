local TurretScript = {}

-- Script properties are defined here
TurretScript.Properties = {
	{ name = "range", type = "number", default = 5000 },
	{ name = "output", type = "entity" },
	{ name = "requiresTarget", type = "boolean", default = true },
	{ name = "requiresSight", type = "boolean", default = true },
	{ name = "owner", type = "entity" },
	{ name = "validTargets", type = "template", container = "array" },
	{ name = "trigger", type = "entity" },
	{ name = "targetEffect", type = "entity" },
	{ name = "targetLoc", type = "entity" }
}

--This function is called on the server when this entity is created
function TurretScript:Init()
	self.targets = {}
	
	self:Schedule(function()
		Wait(2)
		self.properties.trigger.size = Vector.New(self.properties.range, self.properties.range, self.properties.range)
	end)
end

function TurretScript:ClientInit()
	self.targets = {}
end

function TurretScript:FindTarget(entity)
	for i, target in ipairs(self.targets) do 
		if target == entity then 
			return i, target
		end
	end
	
	return
end

function TurretScript:IsTarget(entity)
	if not entity then return end 
	
	for i=1,#self.properties.validTargets do 
		if entity:GetTemplate() == self.properties.validTargets[i] then 
			return true
		else
			if entity.redirectDamageScript and entity.redirectDamageScript.properties.to:GetTemplate() == self.properties.validTargets[i] then 
				return true
			end
		end
	end
	
	return false
end

function TurretScript:HandleTriggerExit(entity)
	local i, target = self:FindTarget(entity)
	if target then 
		table.remove(self.targets, i)
	end
end

function TurretScript:HandleTriggerEnter(entity)
	if self:IsTarget(entity) then 
		table.insert(self.targets, entity)
	end
end

function TurretScript:OnTick()
	local attacking = self:GetEntity():FindScriptProperty("attacking")
	if self.properties.requiresTarget then 
		if #self.targets > 0 then 
			if not attacking then 
				local target = self:FindClosestTarget()
				
				if target and Vector.Distance(target:GetPosition(), self.properties.output:GetPosition()) <= self.properties.range then
					self:_Attack(target)
				end
			end
		end
	else
		if not attacking then 
			self:_Attack()
		end
		
	end
end

--[[
	if self.properties.requiresTarget == false and self.properties.targetEffect then
		print("setting forward")
		self.properties.targetEffect.visible = true
		local vec = target:GetPosition() - self.properties.targetLoc:GetPosition()
		self.properties.targetLoc:SetForward(vec)
	end
--]]

function TurretScript:_Attack(target)
	self:GetEntity():SendToScripts("Attack", target, self.properties.owner)
end

function TurretScript:FindClosestTarget()
	local pos = self.properties.output:GetPosition()
	local targets = {}
	
	if self.properties.requiresSight then 
		for _, target in ipairs(self.targets) do 
			GetWorld():Raycast(
				pos, target:GetPosition(), self:GetEntity(), function(entity)
					if entity == target then
						table.insert(targets, target)
					end
				end
			)
		end	
	else
		targets = self.targets
	end
	
	
	local closestTarget
	local closestDist
	for _, target in ipairs(targets) do
		if closestDist == nil then
			closestDist = Vector.Distance(pos, target:GetPosition())
			closestTarget = target
		else
			local dist = Vector.Distance(pos, target:GetPosition())
			if dist < closestDist then
				closestDist = dist
				closestTarget = target
			end
		end
	end
	
	return closestTarget
end

return TurretScript
