local BallScript = {}

-- Script properties are defined here
BallScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "velocity", type = "number", default = 100 },
	{ name = "isBall", type = "boolean", default = true, edtiable = false }
}

local TIME_TO_CHANGE = 3

--This function is called on the server when this entity is created
function BallScript:Go(dir)
	self:GetEntity():SetVelocity(dir * self.properties.velocity)
	
	self.lastRedirectPos = self:GetEntity():GetPosition()
	
	self.paddles = GetWorld():FindAllScripts("playerPaddleScript")
	
	self:PolitelyInformPaddlesYoureOnYourWay()
end

function BallScript:SetController(controller)
	self.controller = controller
end

function BallScript:AdjustSpeed(speed)
	self.properties.velocity = speed

	self:GetEntity():SetVelocity(self:GetEntity():GetVelocity():Normalize() * speed)
end

function BallScript:AccountForPhasing(hitEntity, hitResult)
	self:MoveToLastPosition()
	self:Redirect(hitEntity, hitResult)
	
end

function BallScript:SimpleRedirect(hitEntity, hitResult)
	local newVel = self:CalcRedirectVelocity(hitEntity, hitResult)
	
	local pos = hitResult:GetPosition()
    self:GetEntity():SetPosition(pos)
	self:GetEntity():SetVelocity(newVel)
	
	--self:PolitelyInformPaddlesYoureOnYourWay()
	
	self.lastRedirectPos = pos
end

function BallScript:CalcRedirectVelocity(hitEntity, hitResult)
	local pos = hitResult:GetPosition()

	local normal = hitResult:GetNormal()
	local vel = self:GetEntity():GetVelocity()
	local dot = Vector.Dot(vel, normal)
	local newVel = -vel + (2 * dot * normal)
	
	return Rotation.New(0, 180, 0):RotateVector(newVel)
end

function BallScript:Descend()
	self:GetEntity():AlterPosition(Vector.New(0, 0, -15000), TIME_TO_CHANGE)
end

function BallScript:MoveToLastPosition()
	if not self.lastTickPosition then return end 
	
	
	local dist = math.abs(Vector.Distance(self:GetEntity():GetPosition(), self.lastTickPosition))
	
	local dir = self:GetEntity():GetVelocity():Normalize()
	
	
	self:GetEntity():SetPosition(self:GetEntity():GetPosition() - (dir * 100))
end

function BallScript:OnTick()
	local pos = self:GetEntity():GetPosition()
	if Vector.Distance(Vector.Zero, pos) > self.controller.diameter then 
		self.controller:RemoveBall(self:GetEntity())
		self:GetEntity():Destroy()
		self.controller:SpawnBall()
	end
	
	self.lastTickPosition = self.tickPosition
	self.tickPosition = pos
end

function BallScript:CheckIfPhasedThroughPaddle(paddleInQuestion, cb)
	local balls = self.controller.balls
	local ignoredEntities = {}
	for _, paddle in ipairs(self.paddles) do 
		table.insert(ignoredEntities, paddle.properties.baseTrigger)
		--table.insert(ignoredEntities, paddle.properties.bounceTrigger)
		table.insert(ignoredEntities, paddle.properties.inactiveTrigger)
		table.insert(ignoredEntities, paddle.properties.safeguardTrigger)
		if paddle.properties.paddle ~= paddleInQuestion then 
			table.insert(ignoredEntities, paddle.properties.paddle)
		end
	end
	for _, ball in ipairs(balls) do 
		table.insert(ignoredEntities, ball)
	end
	
	local bounds = self.controller.properties.mapBounds
	for i=1,#bounds do 
		table.insert(ignoredEntities, bounds[i])
	end
	
	self:CheckIfPhasedThroughPaddleRayCast(self.lastRedirectPos, self:GetTargetRay(), ignoredEntities, cb)
	
	--[[
	GetWorld():Raycast(self.lastRedirectPos, self:GetEntity():GetPosition(), ignoredEntities, function(hitEntity, hitResult)		
		if hitEntity and (hitEntity:GetName() == "paddle" or hitEntity:GetName() == "paddleRed1") then 
			cb(hitEntity, hitResult)
		else
			if hitEntity then 
				print("print didn't phase throughpaddle", hitEntity:GetName())
			end
			
			cb(false)
		end
	end)
	]]--
end

function BallScript:CheckIfPhasedThroughPaddleRayCast(start, last, ignored, cb)
	GetWorld():Raycast(start, last, ignored, function(hitEntity, hitResult)	
		if not hitEntity then 
			cb(false)
			return
		end
		
		if hitEntity and (hitEntity:GetName() == "paddle" or hitEntity:GetName() == "paddleRed1") then 
			print("ball phased, fixing...")
			cb(hitEntity, hitResult)
		else
			print("Phase hit unknown entity", hitEntity:GetName())
			table.insert(ignored, hitEntity)
			
			self:CheckIfPhasedThroughPaddleRayCast(start, last, ignored, cb)
		end
	end)
end

function BallScript:PolitelyInformPaddlesYoureOnYourWay()	
	if not self.paddles then return end 
	
	local balls = self.controller.balls
	local ignoredEntities = {}
	for _, paddle in ipairs(self.paddles) do 
		table.insert(ignoredEntities, paddle.properties.bounceTrigger)
		table.insert(ignoredEntities, paddle.properties.inactiveTrigger)
		table.insert(ignoredEntities, paddle.properties.paddle)
	end
	for _, ball in ipairs(balls) do 
		table.insert(ignoredEntities, ball)
	end
	
	self:FollowRay(self:GetEntity():GetPosition(), self:GetEntity():GetPosition() + (self:GetEntity():GetVelocity():Normalize() * 1000000), ignoredEntities)
end

function BallScript:FollowRay(pos, target, ignore) 
	ignore = ignore or {}
	GetWorld():Raycast(pos, target, ignore, function(hitEntity, hitResult)
		if not hitEntity then return end 
		
		local paddle = self:FindPlayerPaddle(hitEntity)
		if paddle then 
			paddle:HandleIncomingBall(self, hitResult)
		else
			table.insert(ignore, hitEntity)
			local newVel = self:CalcRedirectVelocity(hitEntity, hitResult)
			self:FollowRay(hitResult:GetPosition(), newVel:Normalize() * 1000000, ignore)
		end
	end)
end

function BallScript:Pause()
	if self.paused then return end 
	
	self.paused = true
	self.prevVel = self:GetEntity():GetVelocity()
	
	self:GetEntity():SetVelocity(Vector.Zero)
end

function BallScript:Unpause()
	if not self.paused then return end 
		
	self.paused = false
end

function BallScript:GetTargetRay()
	local dir = (self.lastRedirectPos - self:GetEntity():GetPosition()):Normalize()
	return self.lastRedirectPos - (dir * 100000)
end

function BallScript:Redirect(hitEntity, hitResult)
	local relPos = hitResult:GetRelativePosition()

	local paddleScript = self:FindPlayerPaddle(hitEntity)
	if not paddleScript then return end 
	
	local scale = paddleScript.properties.bounceTrigger.size.y / 2
	local x = relPos.x
	local xx = x / scale
	
	local maxBounceAngle = math.rad(65)
	local bounceAngle = xx * maxBounceAngle;
	
	local vy = self.properties.velocity * -math.cos(bounceAngle);
	local vx = self.properties.velocity * math.sin(bounceAngle);

	local velocity = hitEntity:GetRotation():RotateVector(Vector.New(vx, vy, 0))
	--self:MoveToLastPosition()
	--self:GetEntity():SetPosition(hitResult:GetPosition())
	self:GetEntity():SetVelocity(velocity)
	
	--[[
	local a = Vector.Zero -- local mid point 
	local b = Vector.New(x, -math.abs(x), 0) -- pretend we're at an angle
	local c = (b-a):Normalize() -- get relative bounce vector
	local d = hitEntity:GetRotation():RotateVector(c)

	if d.x == 0 and d.y == 0 then 
		self:GetEntity():SetVelocity(-self:GetEntity():GetVelocity())
	else
		self:GetEntity():SetVelocity(d * self.properties.velocity)
	end
	]]--
	self.lastRedirectPos = hitResult:GetPosition()
	self:PolitelyInformPaddlesYoureOnYourWay()
end

function BallScript:FindPlayerPaddle(hitEntity)
	local target = hitEntity 
	while target ~= nil do 
		if target.playerPaddleScript then 
			return target.playerPaddleScript
		else
			target = target:GetParent()
		end
	end
end

return BallScript
