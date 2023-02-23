local PlayerPaddleScript = {}

-- Script properties are defined here
PlayerPaddleScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "isPaddle", type = "boolean", default = true, editable = false },
	{ name = "paddle", type = "entity" },
	{ name = "camera", type = "entity" },
	{ name = "leftDown", type = "boolean", editable = false },
	{ name = "rightDown", type = "boolean", editable = false },
	{ name = "user", type = "entity", editable = false },
	{ name = "ballSpawn", type = "entity" },
	{ name = "defaultBallTemplate", type = "template" },
	{ name = "baseTrigger", type = "entity" },
	{ name = "width", type = "number", default = 1000 },
	{ name = "speed", type = "number", default = 350 },
	{ name = "out", type = "boolean", default = false, editable = false },
	{ name = "paused", type = "boolean", default = false, editable = false },
	{ name = "bounceTrigger", type = "entity" },
	{ name = "activePaddle", type = "entity" },
	{ name = "inactivePaddle", type = "entity" },
	{ name = "health", type = "number", default = 100 },
	{ name = "activeVoxel", type = "voxelasset" },
	{ name = "inactiveVoxel", type = "voxelasset" },
	{ name = "safeguardTrigger", type = "entity" },
	{ name = "difficulty", type = "number", default = 1 },
	{ name = "bounceSound", type = "soundasset" },
	{ name = "deathSound", type = "soundasset" },
	{ name = "movingSound", type = "soundasset" },
	{ name = "missSound", type = "soundasset" }
}

local TIME_TO_CHANGE = 3

--This function is called on the server when this entity is created
function PlayerPaddleScript:Init()
	self.widget = self:GetEntity():FindWidget("playerNameWidget", true)
	self.targets = {}
	self:DrawPaddle()
	
	self.properties.difficulty = math.random()
end

function PlayerPaddleScript:ScaleBallPosition(scale)
	if not self.ball then return end 
	
	self.ball:AlterPosition(Vector.Zero, 2)
end

function PlayerPaddleScript:HandleOut(entity)
	if self.properties.out or not entity:FindScriptProperty("isBall") then return end 
	
	entity:SendToScripts("CheckIfPhasedThroughPaddle", self.properties.paddle, function(hitEntity, hitResult)
		if hitEntity then 
			print("Accounting for phasing", hitEntity:GetName())
			entity:SendToScripts("AccountForPhasing", hitEntity, hitResult)
		else
			--print(entity:GetName())
			--[[
			if not self.controller:EliminatePlayer(self) then return end 
			
			if self.ball and self.ball:IsValid() then 
				self.ball:Destroy()
			end
			
			self.properties.out = true
			self:GetEntity():CancelTimeline(self.updatePositionTimeline)
			self.widget.properties.out = true
			self.properties.baseTrigger.active = false 
			self.properties.paddle.collisionEnabled = false
			self.properties.bounceTrigger.active = false
			self.properties.activePaddle.visible = false
			self.properties.inactivePaddle.visible = true
			
			self:GetEntity():AlterPosition(self:GetEntity():GetPosition() - Vector.New(0, 0, 15000), 120)
			--]]
			
			self.properties.health = self.properties.health - 10
			if self.properties.health <= 0 then 
				self.controller:EliminatePlayer(self)
				self.properties.out = true
				self.properties.baseTrigger.active = false 
				self.properties.paddle.collisionEnabled = false
				self.properties.bounceTrigger.active = false
				self.properties.activePaddle.visible = false
				self.properties.inactivePaddle.visible = true
				
				self:GetEntity():AlterPosition(self:GetEntity():GetPosition() - Vector.New(0, 0, 15000), 5)
				if self.properties.user then 
					--self.properties.user:SendToScripts("PlaySound2D", self.properties.deathSound)
				end
			else
				local pctLeft = self.properties.health / 100
				self.properties.width = 1000 * pctLeft
				self:DrawPaddle()
				self.controller:RemoveBall(entity)
				self.controller:SpawnBall()
				entity:Destroy()
				
				if self.properties.user then 
					self.properties.user:SendToScripts("DoOnLocal", self:GetEntity(), "PlayMissSound")
				end

			end
		end
	end)
end

function PlayerPaddleScript:PlayMissSound()
	self:Schedule(function()
		local handle = self:GetEntity():PlaySound2D(self.properties.missSound)
		Wait(0.05)
		self:GetEntity():StopSound(handle, 0.1)
	end)
end

function PlayerPaddleScript:DrawPaddle()
	self.properties.activePaddle:ResetVoxels()
	local size = Vector.New(math.ceil(self.properties.width), 50, 50)
	self.properties.bounceTrigger.size = Vector.New(50, math.ceil(self.properties.width), 50)
	self.properties.activePaddle:SetVoxelBox(Vector.Zero, size, self.properties.activeVoxel)
	--self.properties.inactivePaddle:SetVoxelBox(self.properties.inactivePaddle:GetPosition(), self.properties.width / 2, self.properties.inactiveVoxel)
end

function PlayerPaddleScript:Cleanup()
	if self.ball and self.ball:IsValid() then 
		self.ball:Destroy()
	end
	self:GetEntity():Destroy()
end

function PlayerPaddleScript:SetController(controller)
	self.controller = controller
end

function PlayerPaddleScript:UpdatePosition(pos, rot)
	--self:GetEntity():CancelTimeline(self.updatePositionTimeline)
	
	local cur = self:GetEntity():GetRotation()
	
	local rotB = Rotation.New(rot.pitch, rot.yaw + 360, rot.roll)
	local rotC = Rotation.New(rot.pitch, rot.yaw - 360, rot.roll)
	
	local diff = math.abs(cur.yaw - rot.yaw)
	local bDiff = math.abs(cur.yaw - rotB.yaw)
	local cDiff = math.abs(cur.yaw - rotC.yaw)
	
	local rotToUse = rot
	
	if bDiff < diff then 
		rotToUse = rotB
		diff = bDiff
	end
	
	if cDiff < diff then 
		rotToUse = rotC
		diff = cDiff
	end
	
	rot = rotToUse

	if cur.yaw < rot.yaw then 
		--rot.yaw = rot.yaw - 360
	end
	
	self.updatePositionTimeline = self:GetEntity():PlayTimeline(
		0, self:GetEntity():GetPosition(), self:GetEntity():GetRotation(), "EaseInOut",
		TIME_TO_CHANGE, pos, rot, "EaseInOut"
	)
end

function PlayerPaddleScript:UpdateRotation(rot)
	self:GetEntity():CancelTimeline(self.updateRotationTimeline)

	self.updateRotationTimeline = self:GetEntity():PlayTimeline(
		0, self:GetEntity():GetRotation(), "EaseInOut",
		TIME_TO_CHANGE, rot, "EaseInOut"
	)
end

function PlayerPaddleScript:SetUser(user)
	if not user then return end 
	
	self.properties.user = user
	
	local cameraPos = self.properties.camera:GetPosition()
	cameraPos.z = 7000
	self.properties.camera:SetPosition(cameraPos)
	user:SetCamera(self.properties.camera)
	user.userEventsScript.properties.onButtonPressed:Listen(self, "HandleButtonPressed")
	user.userEventsScript.properties.onButtonReleased:Listen(self, "HandleButtonReleased")
	
	self:SetName(tostring(user:GetUsername()))
end

function PlayerPaddleScript:SetName(name)
	self.name = name
	self.widget.properties.name = name
end

function PlayerPaddleScript:UpdateBaseSize(size)
	self.properties.baseTrigger.size = Vector.New(200, size, 50)
	self.properties.safeguardTrigger.size = self.properties.baseTrigger.size
end

function PlayerPaddleScript:SetCameraHeight(height)
	local pos = self.properties.camera:GetRelativePosition()
	self.properties.camera:AlterRelativePosition(Vector.New(pos.x, pos.y, height), 3)
end

function PlayerPaddleScript:GetBallTemplate()
	if self.properties.user then 
		local user = self.properties.user
		local db = user and user.documentStoresScript.default
		local data = db:FindOne() or {}
		
		return data.ballTemplate or self.properties.defaultBallTemplate
	else 
		return self.properties.defaultBallTemplate
	end
end

-- this is only used for the bot
function PlayerPaddleScript:HandleIncomingBall(ball, hitResult)
	if self.properties.user then return end 
	
	local ind = self:FindTarget(ball:GetEntity())
	if ind then 
		table.remove(self.targets, ind)
	end

	table.insert(self.targets, { hitEntity = ball:GetEntity(), hitResult = hitResult })
	self:Start()
end

function PlayerPaddleScript:SpawnBall()

	local ballTemplate = self:GetBallTemplate()
	
	self.ball = GetWorld():Spawn(ballTemplate, self.properties.ballSpawn)
	self.ball:AttachTo(self:GetEntity())
	self.ball:SetPosition(self.properties.ballSpawn:GetPosition())
	self:Schedule(function()
		Wait(3.5)
		self.ball:SendToScripts("Go", -self:GetEntity():GetForward())
	end)
end

function PlayerPaddleScript:CleanTargets()
	for i=#self.targets,1,-1 do 
		local target = self.targets[i]
		if not target.hitEntity:IsValid() then 
			table.remove(self.targets, i)
		end
	end
end

function PlayerPaddleScript:Start()
	if self.properties.user then
		return
	end 
	
	
	local size = self.properties.width / 2 
	local numSecondsToWait = math.random()
	
	if self.schedule then 
		self:Cancel(self.schedule)
	end
	
	self.schedule = self:Schedule(function()
		--Wait(1)
		while true do 
			local pos = self.properties.paddle:GetRelativePosition()
			self:SortTargets()
			local target = self.targets[1] and self.targets[1].hitResult:GetRelativePosition()
			
			if target then 
				if target.y < pos.y then 
					self.properties.leftDown = true
				elseif target.y > pos.y then 
					self.properties.rightDown = true
				end
				numSecondsToWait = math.random() * self.properties.difficulty
			else -- if there's no target, just move randomly
				local dir = math.random(1, 3)

				if dir == 1 then 
					-- do nothing
				elseif dir == 2 then 
					self.properties.rightDown = true
				elseif dir == 3 then 
					self.properties.leftDown = true
				end
			end
			
			Wait(numSecondsToWait)
			
			self.properties.rightDown = false 
			self.properties.leftDown = false 
			
			numSecondsToWait = math.random()
			
		end
	end)
end

function PlayerPaddleScript:SetPaddle()
	local templateName
	if self.properties.user then 
		local db = self.properties.user.documentStoresScript:GetDb("default")
		local doc = db:FindOne()
		templateName = doc.equippedCustomization
	else 
		templateName = "ShowTriggerAsset (Red)"
	end
	local paddle = GetWorld():FindTemplate(templateName)
	self.properties.baseTrigger.showTriggerScript.properties.lineTemplate = paddle
	self.properties.baseTrigger.showTriggerScript:Enable()
end

function PlayerPaddleScript:HandleCollision(entity)	
	if not entity:FindScriptProperty("isBall") then 
		return 
	end

	local ignoredEntities = { unpack(self.controller.balls) }
	for _, paddle in ipairs(self.controller.paddles) do 
		if paddle ~= self:GetEntity() then 
			table.insert(ignoredEntities, paddle.playerPaddleScript.properties.bounceTrigger)
			table.insert(ignoredEntities, paddle.playerPaddleScript.properties.inactiveTrigger)
			table.insert(ignoredEntities, paddle.playerPaddleScript.properties.paddle)
		end
	end
	
	for i=1,#self.controller.properties.mapBounds do 
		table.insert(ignoredEntities, self.controller.properties.mapBounds[i])
	end
		
	GetWorld():Raycast(entity.ballScript.lastRedirectPos, entity.ballScript:GetTargetRay(), ignoredEntities, function(hitEntity, hitResult)
		if not hitEntity then return end 
		
		local ind = self:FindTarget(entity)
		if ind then 
			table.remove(self.targets, ind)
		end
		
		if self.properties.user then 
			self.properties.user:SendXPEvent("bounce")
			self.properties.user:AddToLeaderboardValue("most-bounces", 1)
			self.properties.user:SendToScripts("PlaySound2D", self.properties.bounceSound)
		end
		entity:SendToScripts("Redirect", hitEntity, hitResult)
	end)
end

function PlayerPaddleScript:HandleSafeguard(entity)
	if entity:FindScriptProperty("isBall") then 
		self.controller:RemoveBall(entity)
		entity:Destroy()
		self.controller:SpawnBall()
	end
end

function PlayerPaddleScript:SortTargets()
	self:CleanTargets()
	table.sort(self.targets, function(a,b)
		local distA = Vector.Distance(self:GetEntity():GetPosition(), a.hitEntity:GetPosition())
		local distB = Vector.Distance(self:GetEntity():GetPosition(), b.hitEntity:GetPosition())
		
		return distA < distB
	end)
end

function PlayerPaddleScript:FindTarget(entity)
	for i, target in ipairs(self.targets) do 
		if target.hitEntity == entity then 
			return i
		end
	end
end

function PlayerPaddleScript:HandleLocalButtonPressed(btn)
	if btn == "right" or btn == "left" then 
		--self.soundHandle = self:GetEntity():PlaySound2D(self.properties.movingSound)
	end
end

function PlayerPaddleScript:HandleLocalButtonReleased(btn)
	if self.soundHandle then 
		self:GetEntity():StopSound(self.soundHandle, 0.25)
	end
end

function PlayerPaddleScript:HandleButtonPressed(btn)
	if self.properties.user then 
		self.properties.user:SendToScripts("DoOnLocal", self:GetEntity(), "HandleLocalButtonPressed", btn)
	end
	if btn == "right" then 
		self.properties.rightDown = true
	elseif btn == "left" then 
		self.properties.leftDown = true
	end
end

function PlayerPaddleScript:HandleButtonReleased(btn)
	if self.properties.user then 
		self.properties.user:SendToScripts("DoOnLocal", self:GetEntity(), "HandleLocalButtonReleased", btn)
	end
	if btn == "right" then 
		self.properties.rightDown = false
	elseif btn == "left" then 
		self.properties.leftDown = false 
	end
end

function PlayerPaddleScript:Pause()
	self.properties.paused = true
	self.properties.baseTrigger.active = false 
	self.properties.paddle.collisionEnabled = false
	self.properties.bounceTrigger.active = false
	self.properties.paddle:AlterRelativePosition(Vector.Zero, 2)
end

function PlayerPaddleScript:Unpause()
	if self.properties.out then return end 
	
	self.properties.paused = false
	self.properties.baseTrigger.active = true 
	self.properties.paddle.collisionEnabled = true
	self.properties.bounceTrigger.active = true
end

function PlayerPaddleScript:ProcessButtons(dt)
	if self.properties.out or self.properties.paused then return end 
	
	local p = self.properties.paddle
	
	if not p then return end 
	
	local adjustment = self.properties.speed * dt
	local pos = p:GetRelativePosition()
	local limit = self.properties.width / 2 
	local size = self.properties.baseTrigger.size.y - (self.properties.baseTrigger.size.y / 2)

	
	if self.properties.rightDown and pos.y < (size - limit) then 
		p:SetRelativePosition(pos + Vector.New(0, adjustment, 0))
	elseif self.properties.leftDown and pos.y > -size + limit then 
		p:SetRelativePosition(pos - Vector.New(0, adjustment, 0))
	end
end

function PlayerPaddleScript:Zoom()
	if self.properties.out then return end 
	
	self.properties.camera:PlayRelativeTimeline(
		0, self.properties.camera:GetRelativePosition(), self.properties.camera:GetRelativeRotation(),
		2, self.properties.camera:GetRelativePosition() + Vector.New(1, 0, -150), self.properties.camera:GetRelativeRotation() + Rotation.New(-1.5, 0, 0)
	)
end

function PlayerPaddleScript:OnTick(dt)
	self:ProcessButtons(dt)
end

function PlayerPaddleScript:ClientOnTick(dt)
	self:ProcessButtons(dt)
end

return PlayerPaddleScript
