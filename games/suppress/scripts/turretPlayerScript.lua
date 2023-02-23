local TurretPlayerScript = {}

-- Script properties are defined here
TurretPlayerScript.Properties = {
	{ name = "range", type = "number", default = 5000 },
	{ name = "output", type = "entity" },
	{ name = "requiresTarget", type = "boolean", default = true },
	{ name = "requiresSight", type = "boolean", default = true },
	{ name = "owner", type = "entity" },
	{ name = "validTargets", type = "template", container = "array" },
	{ name = "trigger", type = "entity" },
	{ name = "targetEffect", type = "entity" },
	{ name = "targetLoc", type = "entity" },
	{ name = "parentLocator", type = "entity" },
}

--This function is called on the server when this entity is created
function TurretPlayerScript:Init()
		
	self.properties.trigger.onTriggerEnter:Listen(self, "HandleTriggerEnter")
	self.properties.trigger.onTriggerExit:Listen(self, "HandleTriggerExit")
	
	self:Schedule(function()
		Wait(1)
		self.properties.trigger.size = Vector.New(self.properties.range, self.properties.range, self.properties.range)
	end)
	
end

function TurretPlayerScript:LocalInit()
	self.targets = {}
end

function TurretPlayerScript:FindTarget(entity)
	for i, target in ipairs(self.targets) do 
		if target == entity then 
			return i, target
		end
	end
	
	return
end

function TurretPlayerScript:IsTarget(entity)
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

function TurretPlayerScript:HandleTriggerExit(entity)
	if IsServer() then 
		self:SendToLocal("HandleTriggerExit", entity)
		return
	end
	
	local i, target = self:FindTarget(entity)
	if target then 
		table.remove(self.targets, i)
	end
end

function TurretPlayerScript:HandleTriggerEnter(entity)
	if IsServer() then 
		self:SendToLocal("HandleTriggerEnter", entity)
		return
	end
	if self:IsTarget(entity) then 
		table.insert(self.targets, entity)
	end
end

function TurretPlayerScript:OnTick()
	self.properties.parentLocator:SetRotation(Rotation.Zero)
end

function TurretPlayerScript:TargetBeam(bool,target)
	if bool and target then
		self.localBeam = true
		self.currentTarget = target
	else
		self.localBeam = false
		self.currentTarget = nil
	end
end


function TurretPlayerScript:LocalOnTick()
	self:UpdateAttack()
	self:UpdateIndicator()
end

function TurretPlayerScript:UpdateAttack()
	if self.properties.requiresTarget then 
		if #self.targets == 0 then return end 
		
		local target = self:FindClosestTarget()
		
		if target and Vector.Distance(target:GetPosition(), self.properties.output:GetPosition()) <= self.properties.range then
			self:SendToServer("_Attack", target)
			if target and self.properties.targetEffect then
				--self:SendToLocal("TargetBeam",true,target)
				self:TargetBeam(true, target)
				self.properties.targetEffect.visible = true
				local vec = target:GetPosition() - self.properties.targetLoc:GetPosition()
				self.properties.targetLoc:SetForward(vec)
			else
				self:TargetBeam(false, nil)
				--self:SendToLocal("TargetBeam",false,nil)				
			end
		else
			self.properties.targetEffect.visible = false
		end
	else
		self:SendToServer("_Attack")
	end
end

function TurretPlayerScript:UpdateIndicator()
	self.properties.parentLocator:SetRotation(Rotation.Zero)
	
	if self.localBeam and self.currentTarget and Entity.IsValid(self.currentTarget) then
		self.properties.targetEffect.visible = true
		local vec = self.currentTarget:GetPosition() - self.properties.targetLoc:GetPosition()
		self.properties.targetLoc:SetForward(vec)
	else
		self.properties.targetEffect.visible = false
	end
end

function TurretPlayerScript:_Attack(target)
	local attacking = self:GetEntity():FindScriptProperty("attacking")

	if not attacking then 
		self:GetEntity():SendToScripts("Attack", target, self.properties.owner)
	end
end

function TurretPlayerScript:FindClosestTarget()
	local pos = self.properties.output:GetPosition()
	local targets = {}
	
	for i=#self.targets,1,-1 do 
		if not Entity.IsValid(self.targets[i]) then 
			table.remove(self.targets, i)
		else 
			for _, target in ipairs(self.targets) do 
				GetWorld():Raycast(
					pos, target:GetPosition(), self:GetEntity(), function(entity)
						if entity == target then
							table.insert(targets, target)
						end
					end
				)
			end	
		end
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

return TurretPlayerScript
