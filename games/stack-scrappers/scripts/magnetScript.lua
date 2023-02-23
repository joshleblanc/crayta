local MagnetScript = {}

-- Script properties are defined here
MagnetScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "target", type = "entity", editable = false },
	{ name = "friction", type = "number" },
	{ name = "accel", type = "number" },
	{ name = "debrisEffect", type = "entity" },
	{ name = "debrisDelay", type = "number", default = 0.5 },
	{ name = "trigger", type = "entity" },
	{ name = "holdingThing", type = "boolean", editable = false, default = false },
	{ name = "waiting", type = "boolean", editable = false, default = false },
	{ name = "deathCam", type = "entity" },
	{ name = "decoy", type = "template"},
	{ name = "dropOffPoint", type = "entity" },
	{ name = "thingBeingHeld", type = "entity", editable = false },
	{ name = "poofEffect", type = "effectasset" },
	{ name = "slamSound", type = "soundasset" },
	{ name = "shredderDoor1", type = "entity" },
	{ name = "shredderDoor2", type = "entity" },
	{ name = "gameController", type = "entity" },
	{ name = "pickupSound", type = "entity" },
	{ name = "pickupSound2", type = "entity" },
	{ name = "attachPosition", type = "entity" },
	{ name = "gearTemplate", type = "template" },
	{ name = "pullStartLocator", type = "entity" },
	{ name = "randomTips", type = "text", container = "array" },
	{ name = "magnetHuntingYouMsg", type = "text" },
	{ name = "magnetIsHuntingPlayerMsg", type = "text" },
	{ name = "scrappedMsg", type = "text" },
	{ name = "pulling", type = "boolean", default = false, editable = false },
	{ name = "magnetSlowRange", type = "number", default = 1000 },
	{ name = "targetMode", type = "string", options = { "score", "random", "sequential", "none" }, default = "score" },
	{ name = "hunting", type = "boolean", default = false, editable = false }
}


function MagnetScript:Init()
	self:ClientInit()
	self:DebrisSchedule()
	self.activated = false
	self.userToRespawn = nil	
	self.properties.trigger.onTriggerEnter:Listen(self, "HandleCatch")
	self.initialPosition = self:GetEntity():GetPosition()
	
end

function MagnetScript:DebrisSchedule()
	self:Schedule(function()
		while(true) do
			Wait(self.properties.debrisDelay)
			self.properties.debrisEffect.active = false
			Wait(.5)
			self.properties.debrisEffect.active = true
		end
	end)
end

function MagnetScript:HandleCatch(target)
	if target:IsA(Character) and not self.properties.holdingThing and not self.activated then
		print("HandleCatch called on: " .. target:GetName())
		self.activated = true
		
		self:Schedule(
			function()
				local user = target:GetUser()
				-- check if the target is safe (inside safe trigger)
				if target.SafeScript.properties.safe then
					Print("PLAYER IS SAFE")
					local result, bool = target.SafeScript:ProcessSafety()
					if bool then
						user:DespawnPlayer()
						user:SetCamera(self.properties.deathCam, 0.2)
						self.userToRespawn = user
						local bottomCart = true	
						self:PullUp(result,user, bottomCart)
					else
						self:PullUp(result)
					end
					
					--Remove top train
				else
					
					user:DespawnPlayer()
					user:SetCamera(self.properties.deathCam, 0.2)
					local decoy = GetWorld():Spawn(self.properties.decoy, target:GetPosition(), target:GetRotation())		
					decoy:SendToScripts("SetUser", target:GetUser())			
					self.userToRespawn = user	
					self:PullUp(decoy,user)		
				end
			end
		)
		print("schedule run")
	end
end

-- This needs to be called in a schedule
function MagnetScript:PullUp(thing, user, bottomCart)
	GetWorld():ForEachUser(function(user)
		user.userCurrentlyHuntingScript:Hide()
	end)
	self.properties.pulling = true
		
	self.properties.pickupSound.active = true
	self.properties.pickupSound2.active = true
	--self.properties.waiting = true
	
	local diff = thing:GetPosition() - self:GetEntity():GetPosition()
	local rot = thing:GetRotation()  - self:GetEntity():GetRotation()

	if thing:IsA(Character) then
		self.properties.target = thing:GetUser()
	else
		self.properties.target = thing
	end
	
	local vec = Vector.New(0,0,550)
	if user and not bottomCart then 
		vec = Vector.New(0,0,150)
	end
	
	self.properties.waiting = true
	local timeToWait = thing:PlayTimeline({
		0, thing:GetPosition(), thing:GetRotation(),
		2.1, self.properties.attachPosition:GetPosition() - vec, thing:GetRotation(), "EaseIn",
	})
	thing:AttachTo(self:GetEntity())
	
	Wait(timeToWait)

	self.properties.attachPosition:PlayEffect(self.properties.poofEffect, true)
	thing:PlaySound2D(self.properties.slamSound)
	thing.collisionEnabled = false
	--thing:SetPosition(self.properties.attachPosition:GetPosition())
	
	self.properties.waiting = false
	self.properties.thingBeingHeld = thing
    self.properties.holdingThing = true     
    self.properties.pickupSound.active = false
	self.properties.pickupSound2.active = false
	
	if user then
		GetWorld():ForEachUser(function(u)
			if user == u then
				local randtip = math.random(#self.properties.randomTips)
				u:SendToScripts("Shout", self.properties.randomTips[randtip])
			else
				u:SendToScripts("AddNotification", self.properties.scrappedMsg, { player = tostring(user:GetUsername()) })
			end
		end)
		self:ReduceScore(thing,user)
	end
	
	local dropoffPosition = self.properties.dropOffPoint:GetPosition()
	dropoffPosition.z = self:GetEntity():GetPosition().z
	local timeToMove = self:GetEntity():PlayTimeline({
		0, self:GetEntity():GetPosition(), self:GetEntity():GetRotation(),
		6, dropoffPosition, Rotation.Zero, "EaseInOut"
	})
	Wait(timeToMove)
	
	self.properties.shredderDoor1:SendToScripts("Play")
	self.properties.shredderDoor2:SendToScripts("Play")
	print(self.properties.thingBeingHeld:GetName())
	
	self.properties.thingBeingHeld:Detach()
	self.properties.thingBeingHeld.physicsEnabled = true
	self.properties.thingBeingHeld.gravityEnabled = true

	self.properties.hunting = false
	self.activated = false
	if self.userToRespawn and self.userToRespawn:IsValid() then
		print("Respawning")
		self.userToRespawn:SendToScripts("HandleDeath")
		self.userToRespawn = nil
	else
		self.userToRespawn = nil
	end
	
	self:HuntCountdown(8)
	
	self.properties.thingBeingHeld = nil
	self.properties.holdingThing = false
	self.properties.pulling = false
end

function MagnetScript:ReduceScore(thing,user)
	if user:IsValid() then
		local numGears = math.ceil(user:FindScriptProperty("score") / 2)
		print("Spawning " .. numGears .. " gears")
		user.scoreScript.properties.score = user.scoreScript.properties.score - numGears
		
		self:Schedule(function()
			for i=1,numGears do
				local newGear = GetWorld():Spawn(self.properties.gearTemplate, thing:GetPosition(), Rotation.Zero)
				local script = newGear:FindScript("pickupSpawnerScript", true)
				script.properties.recreate = false
				script:ShowPickup()
				script.properties.singlePickup = true
				
				newGear:SendToScripts("Fly")
				
				Wait() -- if we don't wait, the gears will collide with each other
			end
		end)
	end
end

function MagnetScript:ClientInit()
	self.speed = Vector.New(0, 0, 0)
end

function MagnetScript:Reset()
	self.properties.hunting = false
	self.properties.target = nil
	self:GetEntity():SetPosition(self.initialPosition)
	self:SendToAllClients("ClientResetPosition", self.initialPosition)
end

function MagnetScript:ClientResetPosition(position)
	self:GetEntity():SetPosition(position)
end

function MagnetScript:HuntCountdown(time)
	local initialDelay
	
	if type(time) == "number" then 
		initialDelay = time - 3
	else
		initialDelay = 7
	end
	
	GetWorld():ForEachUser(function(user)
		user.userCurrentlyHuntingScript:Hide()
	end)
	
	self:Schedule(function()
		Wait(initialDelay)
		GetWorld():ForEachUser(function(user)
			user:SendToScripts("Shout", "Magnet will activate in 3 seconds")
		end)
		Wait(1)
		GetWorld():ForEachUser(function(user)
			user:SendToScripts("Shout", "Magnet will activate in 2 seconds")
		end)
		Wait(1)
		GetWorld():ForEachUser(function(user)
			user:SendToScripts("Shout", "Magnet will activate in 1 seconds")
		end)
		Wait(1)
		GetWorld():ForEachUser(function(user)
			user:SendToScripts("Shout", "Magnet is on the hunt")
		end)
		self.properties.hunting = true
	end)
end

function MagnetScript:OnTick(dt)
	if IsClient() then
		return
	end
	if self.properties.gameController:FindScriptProperty("isLobby") then return end 
	if not self.properties.hunting then return end 
	
	self:FindThingToMoveTo() -- this is going to set self.properties.target
	self:Follow(dt)
end

function MagnetScript:ClientOnTick(dt)
	if not self.properties.hunting then return end 
	
	self:Follow(dt)
end

function MagnetScript:OnUserLogout(user) 
	if user == self.properties.target then
		self.properties.target = nil
		self.properties.thingBeingHeld = nil
		self.properties.holdingThing = false
		self.properties.waiting = false
		self.activated = false
		self.userToRespawn = nil
	end
end

function MagnetScript:Follow(dt)
	local target = self.properties.target
	
	if target and target:IsA(User) then
		target = target:GetPlayer()
	end
	
	
	-- player is the thing we're moving towards
	if not target or not target:IsValid() then
		return
	end
	
	local targetPosition = target:GetPosition()
	
	-- lookAt is the direction we want to go
	local lookAt = (targetPosition - self:GetEntity():GetPosition()):Normalize()
	lookAt.z = 0

	-- speed is a vector
	-- friction is a scalar
	-- dt is the number of seconds since the last tick
	-- accel is a scalar

	
	self.speed = self.speed + self.properties.accel * lookAt * dt 
	self.speed = self.speed - (self.speed * self.properties.friction * dt)

	-- we can't go up or down. 
	local z = self:GetEntity():GetPosition().z
	local newPosition = self:GetEntity():GetPosition() + (self.speed * dt)
	newPosition.z = z
	
	self:GetEntity():SetPosition(newPosition)
	--self:GetEntity():SetForward(lookAt)
end

function MagnetScript:AlertUsersOfChase()
	if not IsServer() then return end 
	
	GetWorld():ForEachUser(function(user)
		user.userCurrentlyHuntingScript:Show()
	end)
	
	
	GetWorld():ForEachUser(function(user)
		if self.properties.target and user == self.properties.target then
			user:SendToScripts("AddNotification", self.properties.magnetHuntingYouMsg)
			user:SendToScripts("Shout", self.properties.magnetHuntingYouMsg)
		elseif self.properties.target then
			user:SendToScripts("AddNotification", self.properties.magnetIsHuntingPlayerMsg, { player = tostring(self.properties.target:GetUsername()) }) 
		end
		user:SendToScripts("SetHunted", self.properties.target)
	end)
end

function MagnetScript:FindThingBasedOnScore()
	local target
	self.currentScoreLead = 0
	GetWorld():ForEachUser(
		function(userEntity)
			local score = userEntity:FindScriptProperty("score")
			if score > self.currentScoreLead then
				target = userEntity
				self.currentScoreLead = score
			else
			end
		end)
	self.currentScoreLead = 0
	return target
end

function MagnetScript:FindThingBasedOnRandom()
	local users = GetWorld():GetUsers()
	local index = math.random(1, #users)
	return users[index]
end

function MagnetScript:FindThingBasedOnSequence()
	local users = GetWorld():GetUsers()
	self.sequenceIndex = self.sequenceIndex or 0
	self.sequenceIndex = self.sequenceIndex + 1
	if self.sequenceIndex > #users then
		self.sequenceIndex = 1
	end
	return users[self.sequenceIndex]
end

function MagnetScript:FindThingToMoveTo()
	if self.properties.waiting then
		self.properties.target = nil
	elseif self.properties.holdingThing then
		self.properties.target = nil
	else
	
		local target
		if self.properties.targetMode == "score" then
			target = self:FindThingBasedOnScore()
		elseif self.properties.targetMode == "random" and self.properties.target == nil then
			target = self:FindThingBasedOnRandom()
		elseif self.properties.targetMode == "sequential" and self.properties.target == nil then
			target = self:FindThingBasedOnSequence()
		elseif self.properties.targetMode == "none" then
			target = nil
		end
			
		if target ~= nil and target ~= self.properties.target or self.properties.target == nil then
			self.properties.target = target
			self:AlertUsersOfChase()
		end
	end
end

return MagnetScript