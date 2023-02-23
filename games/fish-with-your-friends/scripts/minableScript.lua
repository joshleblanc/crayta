local MinableScript = {}

-- Script properties are defined here
MinableScript.Properties = {
	-- Example property
	{ name = "isHarvestable", type = "boolean", default = "true", default = true },
	{ name = "requiredRole", type = "string", options = { "miner", "lumberjack" } },
	{ name = "health", type = "number", default = 10 },
	{ name = "respawnTime", type = "number", default = 60, tooltip = "In seconds" },
	{ name = "hitSound", type = "soundasset" },
	{ name = "destroySound", type = "soundasset" },
	{ name = "pickupTemplate", type = "template" },
	{ name = "numPickups", type = "number", default = 3 },
	{ name = "impactEffect", type = "effectasset" },
	{ name = "resource", type = "string" },
	{ name = "gameStorageController", type = "entity" }
}

--This function is called on the server when this entity is created
function MinableScript:Init()
	self.destroyed = false
	self.initialHealth = self.properties.health
end

function MinableScript:Destroy()
	self:GetEntity():PlaySound(self.properties.destroySound)
	
	for i=1,self.properties.numPickups do 
		local pickup = GetWorld():Spawn(self.properties.pickupTemplate, self:GetEntity():GetPosition() + Vector.New(math.random(-50, 50), math.random(-50, 50), i * 75), Rotation.Zero)
		pickup:SendToScripts("DropInWorld")
	end
	
	self.destroyed = true
	self.properties.isHarvestable = false

	self:GetEntity():SendToAllClients("Hide")
	self:GetEntity().collisionEnabled = false
	
	self:Schedule(function() 
		Wait(self.properties.respawnTime)
		self:Respawn()
	end)
end

function MinableScript:Show()
	self:GetEntity().visible = true
end

function MinableScript:Hide()
	self:GetEntity().visible = false
end

function MinableScript:Respawn()
	self:SendToAllClients("Show")
	self:GetEntity().collisionEnabled = true
	self.destroyed = false
	self.properties.isHarvestable = true
	self.properties.health = self.initialHealth
end

function MinableScript:OnDamage(damageAmount, damageCauser, hitResult, a)
	if self.destroyed then return end 
	
	self:GetEntity():PlaySoundAtLocation(hitResult:GetPosition(), self.properties.hitSound)
	
	local rotation = Rotation.FromVector((hitResult:GetPosition() - damageCauser:GetPosition()):Normalize())
	
	self:GetEntity():PlayEffectAtLocation(hitResult:GetPosition(), rotation, self.properties.impactEffect)
	
	self.properties.health = self.properties.health - damageAmount
	
	if self.properties.health <= 0 then
		local user = damageCauser:GetUser()
		local team = user:FindScriptProperty("team")
		
		--self.properties.gameStorageController:SendToScripts("Update", FormatString("{1}-{2}-mined", team, self.properties.resource), 1)
		self:Destroy()
	end
end

return MinableScript
