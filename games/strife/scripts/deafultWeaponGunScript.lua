
--[[
	A script which handles the logic for firing guns that are held by the player.
	This script requires the User to have an inventory script attached.
]]

local GunScript = {}

GunScript.Properties = {
	{ name = "damage", type = "number", default = 100.0, },
	{ name = "damageTable", type = "entity", },
	{ name = "damageHumans", type = "boolean", default = true, },
	{ name = "damageTeam", type = "boolean", default = false, },
	{ name = "critMult", type = "number", default = 1.5, },
	{ name = "maxRange", type = "number", default = 1000, },
	{ name = "damageFalloff", type = "boolean", default = true, },
	{ name = "maxRangeDamage", type = "number", default = 50, visibleIf = function(p) return p.damageFalloff end, },
    { name = "bulletsPerShot", type = "number", default = 1, allowFloatingPoint = false, min = 1, max = 20, },
    { name = "maxSpreadAngle", type = "number", default = 0, },
 	{ name = "maxSpreadAngleIronSight", type = "number", default = 0, },
	{ name = "repeatTimer", type = "number", default = 0.5, },
	{ name = "autoFire", type = "boolean", default = true, },
	{ name = "shotSound", type = "soundasset", },
	{ name = "shotVibrationEffect", type = "vibrationeffectasset", },
	{ name = "cantShootSound", type = "soundasset", },
	{ name = "defaultImpactEffect", type = "effectasset", },
	{ name = "defaultImpactSound", type = "soundasset", },
	{ name = "headshotSound", type = "soundasset" },
	{ name = "muzzleFlashEffect", type = "effectasset", },
	{ name = "muzzleFlashLocatorChild", type = "entity", },
	{ name = "fireMsg", type = "text", },
	{ name = "currentShotsInClip", type = "number", allowFloatingPoint = false, editable = false, },
	{ name = "hasLimitedClip", type = "boolean", default = true, },
	{ name = "shotsPerClip", type = "number", visibleIf = function(p) return p.hasLimitedClip end, allowFloatingPoint = false, default = 6, },
	{ name = "startWithFullClip", type = "boolean", visibleIf = function(p) return p.hasLimitedClip end, default = true, },
	{ name = "ammoTemplate", type = "template", visibleIf = function(p) return p.hasLimitedClip end, },
	{ name = "shouldAutoReload", type = "boolean", visibleIf = function(p) return p.hasLimitedClip end, default = true, },
	{ name = "reloadOneAtATime", type = "boolean", visibleIf = function(p) return p.hasLimitedClip end, default = false, },
	{ name = "reloadTime", type = "number", visibleIf = function(p) return p.hasLimitedClip end, default = 2, },
	{ name = "reloadSound", type = "soundasset", visibleIf = function(p) return p.hasLimitedClip end, },
	{ name = "reloadMsg", type = "text", visibleIf = function(p) return p.hasLimitedClip end, },

	{ name = "shouldFireProjectile", type = "boolean", default = false, },
	{ name = "projectileTemplate", type = "template", visibleIf = function(p) return p.shouldFireProjectile end, },
	{ name = "projectileExitVelocity", type = "number", visibleIf = function(p) return p.shouldFireProjectile end, default = 200, },

	{ name = "localPredictBullet", type = "boolean", default = true, },
	{ name = "localTarget", type = "entity", editable = false, },
	{ name = "canSprintWhileInUse", type = "boolean", default = false, },
	
	{ name = "impactPhysics", type="boolean", default = false},
	{ name = "modifyByDamage", type="boolean", default = true, tooltip = "Modify impulse by the weapon damage", visibleIf = function(p) return p.impactPhysics end},
	{ name = "impulseModifier", type="number", default = 100, tooltip = "If modifyByDamage is true this is a multiplier on the damage to form an impulse, otherwise this is absolute impulse.", visibleIf = function(p) return p.impactPhysics end},
	{ name = "throw", type="boolean"},
}


GunScript.StateDebug = false

function GunScript:Init()
	if self.properties.startWithFullClip then
		self.properties.currentShotsInClip = self.properties.shotsPerClip
	else
		self.properties.currentShotsInClip = 0
	end
	self:SetState("ready")
end

function GunScript:OnButtonPressed(button)
	if button == "primary" then
		self.pressingFire = true
		self:Fire(false)
	elseif button == "extra1" then
		self.requestReload = true
		self:Reload() -- this might fail if we're firing, but the storing of requestReload will make it happen when we next go back to the ready state
	end
end

function GunScript:OnButtonReleased(button)
	if button == "primary" then
		self.pressingFire = false
	end
end

function GunScript:OnTick(dt)
	if self.state and self.state.time > 0.0 then
		self.state.time = self.state.time - dt
		if self.state.time <= 0.0 then
			if self.state.onDone then
				self.state.onDone()
			else
				self:SetState("ready")
			end
		end
	end
end

function GunScript:IsState(name)
	return (self.state and self.state.name == name)
end

function GunScript:SetState(name, time, onDone)
	self.state = {
		name = name,
		time = time or 0.0,
		onDone = onDone,
	}
	if GunScript.StateDebug then printf("Gun: Set State {1}", name) end
end

function GunScript:HasAmmo()
	
	if self.properties.hasLimitedClip and self.properties.currentShotsInClip <= 0 then
		return false
	end
	
	return true
	
end

function GunScript:Fire(ignoreState)

	if not ignoreState and not self:IsState("ready") then
		print("Gun: Fire not ready")
		return
	end

	if not self:HasAmmo() then
		if self.properties.cantShootSound then
			self:GetEntity():PlaySound(self.properties.cantShootSound)
		end
		print("Gun: No ammo")
		return false
	end

	local parent = self:GetEntity():GetParent()
	
	if parent:IsA(Character) then
		if not parent:IsAlive() then
			print("Gun: Cannot fire when dead")
			return false
		end
		if self.properties.throw then
			parent:PlayAction("Melee")
		else
			parent:PlayAction("Fire")
		end

		self:GetEntity():SendToScripts("TriggerRecoil", parent, 1)
		
		if not self.properties.canSprintWhileInUse then
			parent.canSprint = false
		end
	end
	
	if self.properties.shotSound then
		self:GetEntity():PlaySound(self.properties.shotSound)
	end
	
	if self.properties.shotVibrationEffect and parent:IsA(Character) then
		parent:PlayVibrationEffect(self.properties.shotVibrationEffect)
	end

	-- Spawn muzzle flash
	if self.properties.muzzleFlashEffect and self.properties.muzzleFlashLocatorChild then
		local loc = self.properties.muzzleFlashLocatorChild
		loc:PlayEffect(self.properties.muzzleFlashEffect, true)
	end

	-- Projectile
	if self.properties.shouldFireProjectile then
		
		-- Sends a generic InitProjectile call with rayStart, rayDirection, velocity, gun entity and parent entity
		local rayStart, rayDirection = self:GetRayStartAndDirection(true)
		local projectile = GetWorld():Spawn(self.properties.projectileTemplate, rayStart, self:GetEntity():GetRotation())
		projectile:SendToScripts("InitProjectile", rayStart, rayDirection, self.properties.projectileExitVelocity, self:GetEntity(), parent)
		
	else

		-- Work out direction and damage for each bullet in the shot
		for i = 1, self.properties.bulletsPerShot do
			
			-- Send bullet and get info on the damage and what it hit
			if self.properties.localPredictBullet and self.properties.bulletsPerShot == 1 and self.localDamage ~= nil then
				self:ProcessBullet(self.localDamage, self.localCrit, self.localHitEntity, self.localHit, self.localRayDirection)
			else
				self:CalculateBullet(
					self.ironSight and self.properties.maxSpreadAngleIronSight or self.properties.maxSpreadAngle,
					function(damage, crit, hitEntity, hit, rayDirection) 
						self:ProcessBullet(damage, crit, hitEntity, hit, rayDirection)
					end
				)
			end
		end
		
	end

	self:SetState(
		"fire", 
		self.properties.repeatTimer, 
		function()
			if not self.properties.autoFire or not self.pressingFire or not self:Fire(true) then
				if not self.properties.canSprintWhileInUse then
					self:GetEntity():GetParent().canSprint = self.attachedToSprintablePlayer
				end
				self:SetState("ready")
				if self.requestReload or (not self:HasAmmo() and self.properties.shouldAutoReload) then
					self:Reload()
				end
			end
		end
	)

	if self.properties.hasLimitedClip then
		self.properties.currentShotsInClip = self.properties.currentShotsInClip - 1
		self:UpdateInventoryData()
	end
	
	return true
	
end

function GunScript:Reload()
	local entity = self:GetEntity()
	
	if not self:IsState("ready") then
		print("Gun: Not ready to reload")
		return false
	end

	self.requestReload = false
	
	if self.properties.currentShotsInClip >= self.properties.shotsPerClip then
		print("Gun: Full Clip")
		return false
	end

	local ammoIncrease = self.properties.reloadOneAtATime and 1 or (self.properties.shotsPerClip - self.properties.currentShotsInClip)

	if self.properties.ammoTemplate then
		local inventoryScript = self:GetEntity():GetParent():GetUser().inventoryScript

		ammoIncrease = math.min(ammoIncrease, inventoryScript:GetTemplateCount(self.properties.ammoTemplate))
		print("Adding ", ammoIncrease)
		if ammoIncrease == 0 then
			print("Gun: No ammo")
			return false
		end
		
		inventoryScript:RemoveTemplate(self.properties.ammoTemplate, ammoIncrease)
	end

	local params = {}
	params.playbackSpeed = 1
	params.events = {}
	
	local canSprintWhileInUse = self.properties.canSprintWhileInUse
	
	params.events.AmmoAdded = function()
		if not Entity.IsValid(entity) then return end 
		
		printf("Gun: Reload AddAmmo {1}", ammoIncrease)
		self:AddAmmo(ammoIncrease)
		if self.properties.reloadSound then
			self:GetEntity():PlaySound(self.properties.reloadSound)
		end
	end

	params.events.OnCompleted = function()
		if not Entity.IsValid(entity) then return end 
		
		print("Gun: Reload OnComplete")
		-- ensure this only happens once using a flag
		if not self.ammoAdded then
			self:AddAmmo(ammoIncrease)
		end
		
		if not canSprintWhileInUse then
			-- re-enable sprinting once the action has been performed, if this player could initially sprint
        	self:GetEntity():GetParent().canSprint = self.attachedToSprintablePlayer
		end
	end

	if self.properties.reloadOneAtATime then
		if not Entity.IsValid(entity) then return end 
		
		params.events.IsReloadComplete = function()
			local isComplete = self.properties.currentShotsInClip >= self.properties.shotsPerClip
			print("Gun: Reload IsReloadComplete", isComplete)
			return isComplete
		end

	end

	self.ammoAdded = false
	
	local parent = self:GetEntity():GetParent()
	
	if self.properties.throw then 
		params.events.AmmoAdded()
		params.events.OnCompleted()
	else 
		parent:PlayAction("Reload", params)
		if not self.properties.canSprintWhileInUse then
			parent.canSprint = false
		end
	end
	

	self:SetState("reloading", self.properties.reloadTime)
	return true
	
end

function GunScript:OnDestroy()
	print("Gun destroyed", self.attachedToSprintablePlayer)
	self:GetEntity():GetParent().canSprint = self.attachedToSprintablePlayer
end

function GunScript:AddAmmo(ammoIncrease)
	self.properties.currentShotsInClip = math.min(self.properties.shotsPerClip, self.properties.currentShotsInClip + ammoIncrease)
	self:UpdateInventoryData()
	self.ammoAdded = true
end

function GunScript:OnHeld(player, data)
	self.inventoryData = data
	if self.inventoryData.currentShotsInClip ~= nil then
		self.properties.currentShotsInClip = self.inventoryData.currentShotsInClip
	end
	
	print("Holding new gun", player.canSprint)
	self.attachedToSprintablePlayer = player.canSprint
end

function GunScript:UpdateInventoryData()
	if self.inventoryData then
		self.inventoryData.currentShotsInClip = self.properties.currentShotsInClip
	end
end

-- Helper for the Prompts package
function GunScript:GetButtonPrompts(prompts)
	prompts.primary = self.properties.fireMsg:Format({name = self:GetEntity():FindScriptProperty("friendlyName") or ""})
	if self.properties.hasLimitedClip and self.properties.currentShotsInClip ~= self.properties.shotsPerClip and self.properties.shotsPerClip > 1 then
		prompts.extra1 = self.properties.reloadMsg:Format({name = self:GetEntity():FindScriptProperty("friendlyName") or ""})
	end
end

function GunScript:OnIronSightStart()
	self.ironSight = true
end

function GunScript:OnIronSightStop()
	self.ironSight = false
end

function GunScript:GetRayStartAndDirection(useGunSight)
	local parent = self:GetEntity():GetParent()
	if parent:IsA(Character) then
		local rayStart, rayEnd
		if useGunSight then
			rayStart = self:GetEntity():GetPosition()
			if self.properties.muzzleFlashLocatorChild then
				rayStart = self.properties.muzzleFlashLocatorChild:GetPosition()
			end
			rayEnd = parent:GetLookAtPos()
		else
			rayStart, rayEnd = parent:GetLookAt()
		end
		return rayStart, (rayEnd - rayStart):Normalize()
	else
		local rayStart = self:GetEntity():GetPosition()
		if self.properties.muzzleFlashLocatorChild then
			rayStart = self.properties.muzzleFlashLocatorChild:GetPosition()
		end
		local rayDirection = -self:GetEntity():GetForward()
		return rayStart, rayDirection
	end
end

function GunScript:CalculateBullet(spreadAngle, callback)

    local rayStart, rayDirection = self:GetRayStartAndDirection(false)

    if spreadAngle > 0 then
		local rayRotation = 
			Rotation.FromVector(rayDirection) + 
			Rotation.New((math.random() - 0.5) * spreadAngle, (math.random() - 0.5) * spreadAngle, 0)
		rayDirection = rayRotation:RotateVector(Vector.New(1, 0, 0))
	end
	
    local parent = self:GetEntity():GetParent()
	local rayLength = self.properties.maxRange + Vector.Distance(rayStart, self:GetEntity():GetPosition())
	
	GetWorld():Raycast(
		rayStart, 
		rayStart + (rayDirection * rayLength), 
		parent, 
		true,
		function(hitEntity, hit)
			if hitEntity then
				local damage, crit = self:CalculateDamage(hitEntity, hit:GetPosition(), hit:GetPartName())
				callback(damage, crit, hitEntity, hit, rayDirection)
			else
				callback(0, false, nil, nil, rayDirection)
			end
		end
	)

	return rayStart, rayDirection
	
end

function GunScript:ProcessBullet(damage, crit, hitEntity, hit, rayDirection)

	local parent = self:GetEntity():GetParent()
	local isTarget = (hitEntity ~= nil) and self:IsTarget(hitEntity)
	local isFatal = false

	-- ApplyDamage
	if damage > 0 then
		-- for human targets store if was alive
		local wasAlive = hitEntity:IsA(Character) and hitEntity:IsAlive()
		
		-- do the damage
		if self.properties.damageTable ~= nil then
			hitEntity:ApplyDamage(damage, hit, rayDirection, parent, self.properties.damageTable.damageTableScript:GetDamageTable())
		else
			print("Applying Damage", hit:GetPartName())
			hitEntity:ApplyDamage(damage, hit, rayDirection, parent)	
		end
   
		-- work out if fatal
		isFatal = wasAlive and not hitEntity:IsAlive()
	end
	
	if hitEntity and hitEntity.physicsEnabled == true and self.properties.impactPhysics then				
		local impulse = rayDirection * (self.properties.modifyByDamage and damage or 1) * self.properties.impulseModifier						
		hitEntity:AddImpulse(impulse)		
	end

	-- effect
	if hit then
		local effect = hitEntity:FindScriptProperty("impactEffect") or self.properties.defaultImpactEffect
		if effect then
			self:GetEntity():PlayEffectAtLocation(hit:GetPosition(), Rotation.FromVector(hit:GetNormal()), effect)
		end
		
		if crit then 
			print("processing crit")
			if self.properties.headshotSound then 
				print("Playing headshot sound")
				parent:GetUser():SendToScripts("PlaySound2D", self.properties.headshotSound)
			end		
		end
		
		local sound = hitEntity:FindScriptProperty("impactSound") or self.properties.defaultImpactSound
		if sound then
			self:GetEntity():PlaySoundAtLocation(hit:GetPosition(), sound)
		end
	end
	
	-- tell owner
	if parent and parent:IsA(Character) then
		-- Tell owner we've fired a bullet
		-- args are:
		-- * weapon entity
		-- * entity hit
		-- * damage done
		-- * was a weapon target
		-- * was a crit hit
		-- * was a fatal hit
		-- * position of hit if there was one
		parent:SendToScripts("OnBulletFired", self:GetEntity(), hitEntity, damage, isTarget, crit, isFatal, hit and hit:GetPosition() or nil)
	end

end

function GunScript:CalculateDamage(hitEntity, hitPos, partName)

	-- don't damage dead
	if hitEntity:IsA(Character) and not hitEntity:IsAlive() then
		return 0, false
	end

	-- no hit humans
	if hitEntity:IsA(Character) and not self.properties.damageHumans then
		return 0, false
	end

	-- no hit team
	if not self.properties.damageTeam then
	
		local hitTeam = hitEntity:IsA(Character) and hitEntity:GetUser():FindScriptProperty("team") or hitEntity:FindScriptProperty("team")
		local parent = self:GetEntity():GetParent()
		
		local parentTeam = parent:IsA(Character) and parent:GetUser():FindScriptProperty("team") or parent:FindScriptProperty("team")
			
		if parentTeam ~= nil and parentTeam ~= 0 and parentTeam == hitTeam then
			return 0, false
		end
				
	end

	local distance = Vector.Distance(self:GetEntity():GetPosition(), hitPos and hitPos or hitEntity:GetPosition())
	
	-- 0 damage beyond the max range
	if distance > self.properties.maxRange then
		return 0, false
	end
	
	-- lerp damage between min and max
	local damage = (self.properties.damageFalloff) and (self.properties.damage - (self.properties.damage - self.properties.maxRangeDamage) * (distance / self.properties.maxRange)) or self.properties.damage
	
	-- calculate if crit
	local crit = false
	
	if hitPos and self.properties.critMult > 1.0 then
		local damageCritScripts = hitEntity:FindAllScripts("damageCritScript")
		for _, damageCritScript in ipairs(damageCritScripts) do
			-- deal with damage crit scripts on trigger boxes
			if damageCritScript:GetEntity():IsA(Trigger) and damageCritScript:GetEntity():IsInside(hitPos) then
				crit = true
				break
			-- deal with damage crit script representing body part
			elseif partName and damageCritScript.properties.bodyPart == partName then
				crit = true
				break
			end			
		end
		if crit then
			damage = damage * self.properties.critMult
		end
	end
	
	damage = self:GetEntity():GetParent():GetUser().modifiersScript:ModifyDamage(damage)
	
	return math.floor(damage), crit

end

function GunScript:UpdateRaycastFromLocal(damage, crit, hitEntity, hit, rayDirection)
	self.localDamage = damage
	self.localCrit = crit
	self.localHitEntity = hitEntity
	self.localHit = hit
	self.localRayDirection = rayDirection
end


function GunScript:LocalOnIronSightStart()
	self.localIronSight = true
end

function GunScript:LocalOnIronSightStop()
	self.localIronSight = false
end

function GunScript:LocalOnTick(dt)
	
	-- if we're a single bullet per shot weapon and we're locally predicting bullets
	-- then send a bullet back to the server, calculate with spray here (unlike below)
	if self.properties.localPredictBullet and self.properties.bulletsPerShot == 1 then
		self:CalculateBullet(
			self.localIronSight and self.properties.maxSpreadAngleIronSight or self.properties.maxSpreadAngle, 
			function(damage, crit, hitEntity, hit, rayDirection)
				self:SendToServer("UpdateRaycastFromLocal", damage, crit, hitEntity, hit, rayDirection)
			end
		)
	end
	
	-- see what is under the cursor, store this off we use it in iron sight and for a cursor
	self.properties.localTarget = nil
	self:CalculateBullet(
		0, -- don't use spread, just look under crosshair 
		function(damage, crit, hitEntity, hit, rayDirection)
			if damage > 0 and self:IsTarget(hitEntity) then
				self.properties.localTarget = hitEntity
			end
		end
	)
end

function GunScript:IsTarget(hitEntity)
	if hitEntity:IsA(Character) then
		return hitEntity:IsAlive() and not hitEntity:FindScriptProperty("isGhost")
	else
		local damageTargetScripts = hitEntity:FindAllScripts("damageTargetScript")
		for _, damageTargetScript in ipairs(damageTargetScripts) do
			if damageTargetScript.properties.entity == hitEntity then
				return true					
			end
		end
	end
	return false
end


return GunScript
