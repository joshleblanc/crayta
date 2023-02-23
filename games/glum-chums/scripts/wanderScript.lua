local WanderScript = {}

-- Script properties are defined here
WanderScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "box", type = "entity" },
	{ name = "acceleration", type = "number", default = 200 },
	{ name = "target", type = "vector", editable = false },
	{ name = "enabled", type = "boolean", default = true },
	{ name = "debug", type = "boolean", default = false },
	{ name = "targetEffect", type = "entity", visibleIf=function(p) return p.debug end },

}

--This function is called on the server when this entity is created
function WanderScript:Init()
	self:IsoInit()
	
	if self.box then 
		self.properties.targetEffect:AttachTo(self.box)
	end
	
	if not self.properties.debug then 
		self.properties.targetEffect.visible = false
	end

	if self.properties.enabled then 
		self:GetNewTarget()
	end
end

function WanderScript:ClientInit()
	self:IsoInit()
end

function WanderScript:IsoInit()
	self:Reattach()
	
	self.friction = 0.8
end

function WanderScript:Reattach(what)
	local pos = self:GetEntity():GetPosition()
	
	if what == nil then 
		self.box = self:GetEntity():GetParent()
	else
		self.box = what
	end
	
	if self.box and IsServer() then 
		self:GetEntity():AttachTo(self.box)
		self:GetEntity():SetPosition(pos)
	end
		
	
	if self.box and self.box:IsA(Trigger) then 
		self.width = self.box.size.x
		self.height = self.box.size.y
	else
		self:Disable()
	end
end

function WanderScript:Disable()
	self:GetEntity():SetVelocity(Vector.Zero)
	self.properties.enabled = false
end

function WanderScript:Enable()
	self.properties.enabled = true
	self:GetNewTarget()
end

function WanderScript:CalcVelocity(dt)
	if not self.properties.target then return end 
	
	local dir = (self.properties.target - self:GetEntity():GetRelativePosition()):Normalize()
	
	local prevVel = self:GetEntity():GetVelocity()
	
	self:GetEntity():SetRelativeRotation(Rotation.FromVector(prevVel))
	
	local friction = -prevVel * self.friction
	
	local force = (dir * self.properties.acceleration) + friction 

	local newVel = prevVel + (force * dt)
	
	self:GetEntity():SetVelocity(newVel)
end

function WanderScript:ClientOnTick(dt)
	if not self.properties.enabled then return end 
		
	self:CalcVelocity(dt)
end

function WanderScript:OnTick(dt)
	if not self.properties.enabled then return end 
		
	self:CalcVelocity(dt)
	
	GetWorld():Raycast(self:GetEntity():GetPosition(), self:GetEntity():GetPosition() + self:GetEntity():GetVelocity(), {}, function(entity, hitResult)
		if entity and not entity:IsA(Trigger) then 
			self:GetNewTarget()
		end
	end)
	
	local dist = Vector.Distance(self:GetEntity():GetRelativePosition(), self.properties.target)
	
	if dist < 50 then
		self:GetNewTarget()
	end
end

function WanderScript:GetNewTarget()
	local x = math.random(-self.width / 2, self.width / 2)
	local y = math.random(-self.height / 2, self.height / 2)
	
	self.properties.target = Vector.New(x, y, self:GetEntity():GetRelativePosition().z)
	
	if self.properties.debug then 
		self.properties.targetEffect:SetRelativePosition(self.properties.target)
	end
end



return WanderScript
