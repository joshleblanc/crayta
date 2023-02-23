local OrbScript = {}

-- Script properties are defined here
OrbScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "lifespan", type = "number" },
	{ name = "despawnEffect", type = "effectasset" },
	{ name = "impactEffect", type = "effectasset" },
	{ name = "damage", type = "number", default = 10 },
	{ name = "objectPool", type = "entity" },
	{ name = "owner", type = "entity", editable = false },
	{ name = "done", type = "boolean", editable = false, default = true },
	{ name = "bornAt", type = "number", editable = false },
}

--This function is called on the server when this entity is created
function OrbScript:Init()
	self.objectPool = self.properties.objectPool
end

function OrbScript:SetOwner(owner)
	self.properties.owner = owner
end

function OrbScript:_SetVelocity(vel)
	self:GetEntity():SetVelocity(vel)
end

function OrbScript:SetVelocity(vel)
	if IsServer() then 
		--self:_SetVelocity(vel)
		self:SendToAllClients("SetVelocity", vel)
	end
	
	self:GetEntity():SetVelocity(vel)
end

function OrbScript:ClientOnTick(dt)
	if self.properties.done then return end 
	if not self.properties.owner then return end 
	
	local dir = (self:GetEntity():GetPosition() + self:GetEntity():GetVelocity() * dt) - self:GetEntity():GetPosition()
	
	self:Raycast(
		self:GetEntity():GetPosition(),
		self:GetEntity():GetPosition() + self:GetEntity():GetVelocity() * dt,
		{ self:GetEntity(), self.properties.owner },
		function(hitEntity, hitResult)
			if hitEntity then
				self.properties.done = true
				self:SendToServer("ApplyDamage", hitEntity, hitResult)
			end
		end
	)
	
	local time = GetWorld():GetUTCTime()

	if self.properties.bornAt > 0 and (time - self.properties.bornAt) > self.properties.lifespan then
		self.properties.done = true
		self:SendToServer("Expired")
	end
end

function OrbScript:Raycast(start, target, ignored, cb)
	GetWorld():Raycast(
		start,
		target,
		ignored,
		function(hitEntity, hitResult)
			if hitEntity then
				if hitEntity.redirectDamageScript and hitEntity.redirectDamageScript.properties.to == self.properties.owner then 
					table.insert(ignored, hitEntity)
					print("SKIPPING", hitEntity:GetName())
					self:Raycast(start, target, ignored, cb)
				else
					cb(hitEntity, hitResult)
				end
			else
				cb(hitEntity, hitResult)
			end
		end
	)
end

function OrbScript:Expired()
--	self.properties.done = true
--	self:GetEntity().visible = false
--	self:GetEntity():PlayEffectAtLocation(self:GetEntity():GetPosition(), self:GetEntity():GetRotation(), self.properties.despawnEffect)
--	self:SetVelocity(Vector.Zero)
	
	self.objectPool.objectPoolScript:ReturnObj(self:GetEntity())
end

function OrbScript:ApplyDamage(hitEntity, hitResult)
--	hitEntity:PlayEffectAtLocation(hitResult:GetPosition(), Rotation.FromVector(hitResult:GetNormal()), self.properties.impactEffect)
	if not hitEntity then return end 
	if not self.properties.owner then return end 
	
	hitEntity:ApplyDamage(self.properties.damage, hitResult, hitResult:GetNormal(), self.properties.owner)
	self.objectPool.objectPoolScript:ReturnObj(self:GetEntity())
--	self.properties.done = true
end

function OrbScript:Enable()
	self.properties.done = false 
	self.properties.bornAt = GetWorld():GetUTCTime()
end

function OrbScript:Disable()
	self.properties.done = true 
	self.properties.bornAt = 0
	self:SetVelocity(Vector.Zero)
end

function OrbScript:OnEnabled()
	self:SendToAllClients("Enable")
end

function OrbScript:OnDisabled()
	self:GetEntity():PlayEffectAtLocation(self:GetEntity():GetPosition(), self:GetEntity():GetRotation(), self.properties.despawnEffect)

	self:SendToAllClients("Disable")
end

return OrbScript
