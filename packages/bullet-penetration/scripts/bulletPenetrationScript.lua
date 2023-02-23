local BulletPenetrationScript = {}

-- Script properties are defined here
BulletPenetrationScript.Properties = {
	-- Example property
	{ name = "pierceResistance", type = "number", default = 100, tooltip = "How strong this material is: A titanium wall might have a very large value, while a bamboo wall might have a very low value" }
}

--This function is called on the server when this entity is created
function BulletPenetrationScript:Init()
	self.impactEffect = self:GetEntity():FindScriptProperty("impactEffect")
	self:GetEntity().damageEnabled = true
	self.isVoxelMesh = self:GetEntity():IsA(VoxelMesh)
end

function BulletPenetrationScript:OnDamage(amt, from, hit)
	local gun = from:FindScriptProperty("heldEntity")
	
	if not gun and gun.gunScript then return end 
	
	local impactEffect = self.impactEffect or gun:FindScriptProperty("defaultImpactEffect")
	
	local rayStart, rayEnd = from:GetLookAt()
	local dir = (rayEnd - rayStart):Normalize()
	local hitPos = hit:GetPosition()
	
	if amt < self.properties.pierceResistance then return end 

	self:FindOtherSide(hitPos, dir, function(hitEntity, rayHit)	
		if not hitEntity or not rayHit then return end 
			
		local rot 
		if self.isVoxelMesh then 
			rot = Rotation.FromVector(Rotation.New(0, 180, 0):RotateVector(rayHit:GetNormal()))
		else 
			rot = Rotation.FromVector(rayHit:GetNormal())
		end
		
		self:GetEntity():PlayEffectAtLocation(rayHit:GetPosition(), rot, impactEffect)
		
		local rayHitPos = rayHit:GetPosition()
		GetWorld():Raycast(rayHitPos + dir, rayHitPos + (dir * 10000), {}, true, function(secondHitEntity, secondRayHit) 
			if not secondRayHit or not secondHitEntity then return end 
			
			self:Schedule(function()
				local damage, crit = gun.gunScript:CalculateDamage(secondHitEntity, secondRayHit:GetPosition(), secondRayHit:GetPartName())
				damage = damage - self.properties.pierceResistance
				if damage > 0 then 
					gun.gunScript:ProcessBullet(damage, crit, secondHitEntity, secondRayHit, dir)
				end
				
			end)

		end)
	end)
end

function BulletPenetrationScript:FindOtherSide(hitPos, dir, cb)
	if self.isVoxelMesh then 
		GetWorld():Raycast(hitPos + dir, hitPos + (dir * 10000), {}, true, cb)
	else 
		self:FindOtherSideOfMesh(hitPos + (dir * 10000), hitPos, {}, cb)
	end
end

function BulletPenetrationScript:FindOtherSideOfMesh(startPos, endPos, ignores, cb)
	GetWorld():Raycast(startPos, endPos, ignores, true, function(hitEntity, hitResult)
		if hitEntity and hitEntity == self:GetEntity() then 
			cb(hitEntity, hitResult)
		else
			if not hitEntity or notHitResult then return end 
			
			table.insert(ignores, hitEntity)
			self:FindOtherSideOfMesh(hitResult:GetPosition(), endPos, ignores, cb)
		end	
	end)
end

return BulletPenetrationScript
