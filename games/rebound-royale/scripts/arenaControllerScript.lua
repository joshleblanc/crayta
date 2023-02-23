local ArenaControllerScript = {}

-- Script properties are defined here
ArenaControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "numSpawns", type = "number", default = 2 },
	{ name = "radius", type = "number", default = 1000 },
	{ name = "playerTemplate", type = "template" },
	{ name = "baseSize", type = "number", default = 5000 },
	{ name = "voxelAsset", type = "voxelasset" },
	{ name = "spectateCamera", type = "entity" },
	{ name = "mapBounds", type = "entity", container = "array" },
	{ name = "ballTemplate", type = "template" },
	{ name = "spawnSound", type = "soundasset" },
	{ name = "deathSound", type = "soundasset" },
}

function shuffle(x)
	for i = #x, 2, -1 do
		local j = math.random(i)
		x[i], x[j] = x[j], x[i]
	end
end

local TIME_TO_CHANGE = 3
local BOT_NAMES = {
	"Jeffery", "Terry", "Stephanie", "Kathy", "Lorissa",
	"Joe", "Trey", "Jen", "Stacy", "Tony",
	"Chris", "Jon", "Debbie", "Kristen", "Molly",
	"Roger", "Bob", "Jill", "Josh", "Nat"
}

--This function is called on the server when this entity is created
function ArenaControllerScript:Init()
	self.winnerWidget = self:GetEntity().winnerWidget
	self.eliminationWidget = self:GetEntity().eliminationWidget
	self.gameController = GetWorld():FindScript("gameScript")
	self.waitingWidget = self:GetEntity().waitingWidget
	self.paddles = {}
	self.allPaddles = {}
	self.balls = {}
end

function ArenaControllerScript:ClientInit()
	self.winnerWidget = self:GetEntity().winnerWidget
	self.eliminationWidget = self:GetEntity().eliminationWidget
	self.gameController = GetWorld():FindScript("gameScript")
	self.waitingWidget = self:GetEntity().waitingWidget
end

function ArenaControllerScript:Countdown()
	self:GetEntity():SendToScripts("Say", "321")
		
	Wait(3.5)
	
	self:GetEntity():SendToScripts("Say", "Go")
end

function ArenaControllerScript:RemoveBall(ballEntity)
	local indToRemove
	for i, ball in ipairs(self.balls) do 
		if ball == ballEntity then 
			indToRemove = i
		end
	end
	
	if indToRemove then 
		table.remove(self.balls, indToRemove)
	end
end

function ArenaControllerScript:SpawnBall(currIncr)

	if not currIncr then 
		local incrementAngle = 360 / #self.paddles
		local cntr = 0
		local options = {}
		for i=1,#self.paddles do 
			table.insert(options, cntr * (0.9 + math.random() * 0.2))
			cntr = cntr + incrementAngle
		end
		currIncr = options[math.random(1,#options)]
	end
	if #self.balls >= (#self.paddles - 1) then return end 
	if self.over then return end 

	
	local ball = GetWorld():Spawn(self.properties.ballTemplate, Vector.Zero, Rotation.Zero)
	table.insert(self.balls, ball)
	
	ball.ballScript.properties.velocity = self:GetSpeed()
	ball:SendToScripts("SetController", self)
	
	local tmpInc = currIncr * (0.9 + math.random() * 0.2)
	local x = 0.5 * math.sin(tmpInc * math.pi / 180)
	local y = 0.5 * math.cos(tmpInc * math.pi / 180)
	local dir = Vector.New(x, y, 0)
	ball:SendToScripts("Go", dir)
	
	self:GetEntity():PlaySound2D(self.properties.spawnSound)
end

function ArenaControllerScript:SpawnBalls()
	if self.over then return end
	
	
	self.ballSpawnSchedule = self:Schedule(function()
		local spawnPoint = Vector.Zero 
		
		for _, ball in ipairs(self.balls) do 
			ball:Destroy()
		end
		
		self.balls = {}
		
		local incrementAngle = 360 / #self.paddles

		
		local currIncr = 0
		
		for i=1,(#self.paddles - 1) do 
			self:SpawnBall(currIncr)
			currIncr = currIncr + incrementAngle
			
			Wait(1 / #self.paddles)
		end
	end)
	
end

function ArenaControllerScript:HandleGameStart()	
	self:GetEntity():SendToScripts("ShutUp")
	if self.announcerSchedule then 
		self:Cancel(self.announcerSchedule)
	end
	
	if self.ballSpawnSchedule then 
		self:Cancel(self.ballSpawnSchedule)
	end
	
	if self.gameStartSchedule then 
		self:Cancel(self.gameStartSchedule)
	end
	
	self.gameStartSchedule = self:Schedule(function()
		for _, paddle in ipairs(self.allPaddles) do 
			paddle:SendToScripts("Cleanup")
		end
		
		Wait()

		for _, ball in ipairs(self.balls) do 
			ball:Destroy()
		end
	
		Wait()
		
		self.paddles = {}
		self.allPaddles = {}
		self.balls = {}
		self.handlingOut = false
		self.over = false
		self.preGame = false
		
		local availNames = { unpack(BOT_NAMES) }
		
		local perimeter = self.properties.numSpawns * self.properties.baseSize
		local radius = perimeter / (2 * math.pi)
		self.diameter = radius * 2
		
		local incrementAngle = 360 / self.properties.numSpawns 
		
		local currIncr = 0
		local users = self.gameController:GetUsers()
		
		if #users == 0 then 
			self.preGame = true
		end
		
		self:DrawBox(math.max(self.diameter, self.properties.baseSize), math.max(self.diameter, self.properties.baseSize), true)
		
		local options = {}
		
		for i=1,self.properties.numSpawns do 
			local user = users[i]
			if user then 
				table.insert(options, user)
			else
				table.insert(options, false)
			end
		end
		
		shuffle(options)
		
		for i=1,self.properties.numSpawns do 
			local user = options[i]
			
			local x = radius * math.sin(currIncr * math.pi / 180)
			local y = radius * math.cos(currIncr * math.pi / 180)

			local pos = Vector.New(x, y, 0)
			local paddle = GetWorld():Spawn(self.properties.playerTemplate, pos, Rotation.FromVector(pos) - Rotation.New(0, -180, 0))
			
			if user then 
				paddle:SendToScripts("SetUser", user)
				
				user:SendToScripts("DoOnLocal", self:GetEntity(), "HideWaiting")
			else
				local nameInd = math.random(1, #availNames)
				local name = availNames[nameInd]
				table.remove(availNames, nameInd)
				paddle:SendToScripts("SetName", FormatString("[BOT] {1}", name))
			end
			
			paddle:SendToScripts("SetPaddle")
			
			paddle:SendToScripts("SetController", self)
			--paddle:SendToScripts("SpawnBall")
			paddle:SendToScripts("UpdateBaseSize", self.properties.baseSize)
			
			table.insert(self.paddles, paddle)
			table.insert(self.allPaddles, paddle)
			currIncr = currIncr + incrementAngle
			
			Wait()
		end
		
		self:Countdown()
		
		self:SpawnBalls()
		for _, paddle in ipairs(self.paddles) do 
			paddle:SendToScripts("Start")
		end
	end)
end

function ArenaControllerScript:GetSpeed()
	local percent = #self.paddles / 20
	return 6000 * math.pow(percent, 0.5)
end

function ArenaControllerScript:EliminatePlayer(paddleScript)
	--if self.handlingOut then return end 
	--self.handlingOut = true
	
	if self.over then return end 
	
	if self.announcerSchedule then 
		self:Cancel(self.announcerSchedule)
	end
	
	self.announcerSchedule = self:Schedule(function()
		if #self.paddles > 16 then 
			self:GetEntity():SendToScripts("Say", "Uhoh")
		elseif #self.paddles > 1 then
			self:GetEntity():SendToScripts("Say", #self.paddles)
			Wait(0.75)
			self:GetEntity():SendToScripts("Say", "Players Left")
		end
		self:Schedule(function()
			Wait(1)
			self.speaking = false
		end)
	end)
	
	self:GetEntity():PlaySound2D(self.properties.deathSound)
	
	self:Schedule(function()

		--GetWorld():BroadcastToScripts("Pause")
		GetWorld():BroadcastToScripts("Zoom")
		Wait()
		
		
		for _, ball in ipairs(self.balls) do 
			ball:SendToScripts("AdjustSpeed", self:GetSpeed())
		end
			
		if #self.paddles > 1 then 
			self.eliminationWidget.properties.name = paddleScript.name
			self:SendToAllClients("ShowEliminationWidgetToPlayers")
		end

		Wait(2)
		
		self:HideEliminationWidget()
		--self:SpawnBalls()
		--GetWorld():BroadcastToScripts("Unpause")
		--self.handlingOut = false
	end)
	
	if paddleScript.properties.user then 
		paddleScript.properties.user:SetCamera(self.properties.spectateCamera, 3)
		paddleScript.properties.user:SendToScripts("DoOnLocal", self:GetEntity(), "ShowWaiting")
	end
	
	local ind = self:FindPaddle(paddleScript:GetEntity())
	if not ind then return end 
	
	local oldPerimiter = #self.paddles * self.properties.baseSize
	local oldDiameter = (oldPerimiter / (2 * math.pi)) * 2
	
	table.remove(self.paddles, ind)
	
	local currIncr = 0
	local perimeter = #self.paddles * self.properties.baseSize
	local radius = perimeter / (2 * math.pi)
	self.diameter = radius * 2
	
	local incrementAngle = 360 / #self.paddles
	
	for i, paddle in ipairs(self.paddles) do 
		local x = radius * math.sin(currIncr * math.pi / 180)
		local y = radius * math.cos(currIncr * math.pi / 180)
		local pos = Vector.New(x, y, 0)
		local rot = Rotation.FromVector(pos) - Rotation.New(0, -180, 0)
		
		paddle:SendToScripts("UpdateBaseSize", self.properties.baseSize)
		paddle:SendToScripts("UpdatePosition", pos, rot)
	--	paddle:SendToScripts("UpdateRotation", rot)
		paddle:SendToScripts("ScaleBallPosition", self.diameter / oldDiameter)
		
		currIncr = currIncr + incrementAngle
	end
	
	self:DrawBox(math.max(self.diameter, self.properties.baseSize), math.max(self.diameter, self.properties.baseSize), false)
	
	if #self.paddles <= 1 then 
		self.gameController:EndPlay()
	end
	
	local hasUser = false
	for _, paddle in ipairs(self.paddles) do 
		if paddle:FindScriptProperty("user") then
			hasUser = true
		end
	end
	
	if not hasUser then 
		self.gameController:EndPlay()
	end
	
	return true
end

function ArenaControllerScript:AnnounceWinner(user)
	local localUser = GetWorld():GetLocalUser()
	
	if localUser == user then 
		self:GetEntity():SendToScripts("Say", "You Win")
	else
		self:GetEntity():SendToScripts("Say", "Game Over")
	end
end

function ArenaControllerScript:ShowWinner()
	self.over = true
	
	if self.announcerSchedule then 
		self:Cancel(self.announcerSchedule)
	end
	
	if #self.paddles == 1 then
		local user = self.paddles[1]:FindScriptProperty("user")
		self:SendToAllClients("AnnounceWinner", self.paddles[1].playerPaddleScript.properties.user)
		self.winnerWidget.properties.name = self.paddles[1].playerPaddleScript.name
		
		if user then 
			user:SendXPEvent("win")
			user:AddToLeaderboardValue("most-wins", 1)
		end
	else
		self:SendToAllClients("AnnounceWinner")
		self.winnerWidget.properties.name = "NO ONE"
	end
	
	for _, paddle in ipairs(self.allPaddles) do 
		local user = paddle:FindScriptProperty("user")
		if user then 
			user:SendXPEvent("play")
			user:AddToLeaderboardValue("most-plays", 1)
		end
	end
	
	self:SendToAllClients("ShowWinnerToPlayers")
	
	for _, ball in ipairs(self.balls) do 
		if ball and ball.Descend then 
			ball:Descend()
		end	
	end
end

function ArenaControllerScript:ShowWinnerToPlayers()
	local user = GetWorld():GetLocalUser()
	if user:FindScriptProperty("inGame") then 
		self.winnerWidget:Show()
	end
end

function ArenaControllerScript:ShowEliminationWidgetToPlayers()
	local user = GetWorld():GetLocalUser()
	if user:FindScriptProperty("inGame") then 
		self.eliminationWidget:Show()
	end
end

function ArenaControllerScript:HideEliminationWidget()
	if IsServer() then 
		self:SendToAllClients("HideEliminationWidget")
		return
	end
	self.eliminationWidget:Hide()
end

function ArenaControllerScript:HideWinner()
	if IsServer() then 
		self:SendToAllClients("HideWinner")
		return
	end
	self.winnerWidget:Hide()
end

function ArenaControllerScript:FindPaddle(paddleEntity)
	for i, paddle in ipairs(self.paddles) do 
		if paddle == paddleEntity then 
			return i
		end
	end
end

function ArenaControllerScript:DrawBox(width, height, immediate)
	width = width + 500 -- 1250
	height = height + 500 --1250
	local halfWidth = width / 2
	local halfHeight = height / 2
	
	local thickness = 50
	
	--[[
	self.properties.map:SetVoxelBox(Vector.New(0, -halfHeight, 0), Vector.New(width, 25, 250), self.properties.voxelAsset)
	self.properties.map:SetVoxelBox(Vector.New(0, halfHeight, 0), Vector.New(width + 2, 25, 250), self.properties.voxelAsset)
	self.properties.map:SetVoxelBox(Vector.New(-halfWidth, 0, 0), Vector.New(25, height + 2, 250), self.properties.voxelAsset)
	self.properties.map:SetVoxelBox(Vector.New(halfWidth, 0, 0), Vector.New(25, height + 2, 250), self.properties.voxelAsset)
	]]--
	
	if immediate then 
		self.properties.mapBounds[1]:SetPosition(Vector.New(0, -halfHeight, 0))
		self.properties.mapBounds[2]:SetPosition(Vector.New(0, halfHeight, 0))
		self.properties.mapBounds[3]:SetPosition(Vector.New(-halfWidth, 0, 0))
		self.properties.mapBounds[4]:SetPosition(Vector.New(halfWidth, 0, 0))
	else 
		self.properties.mapBounds[1]:AlterPosition(Vector.New(0, -halfHeight, 0), TIME_TO_CHANGE)
		self.properties.mapBounds[2]:AlterPosition(Vector.New(0, halfHeight, 0), TIME_TO_CHANGE)
		self.properties.mapBounds[3]:AlterPosition(Vector.New(-halfWidth, 0, 0), TIME_TO_CHANGE)
		self.properties.mapBounds[4]:AlterPosition(Vector.New(halfWidth, 0, 0), TIME_TO_CHANGE)
	end
	
	self.properties.mapBounds[1].size = Vector.New(500, height + 500, thickness)
	self.properties.mapBounds[2].size = Vector.New(500, height + 500, thickness) --15000
	self.properties.mapBounds[3].size = Vector.New(width + 500, 500, thickness)
	self.properties.mapBounds[4].size = Vector.New(width + 500, 500, thickness)
end

function ArenaControllerScript:OnUserLogin(user)
	user:SetCamera(self.properties.spectateCamera)
end

function ArenaControllerScript:ShowWaiting()
	if GetWorld():GetLocalUser():FindScriptProperty("inGame") then 
		self:GetEntity().waitingWidget:Show()
	end
end

function ArenaControllerScript:HideWaiting()
	self:GetEntity().waitingWidget:Hide()
end

function ArenaControllerScript:OnUserJoinGame(user)
	if self.preGame then 
		self:HandleGameStart()
	else
		user:SetCamera(self.properties.spectateCamera)
		user:SendToScripts("DoOnLocal", self:GetEntity(), "ShowWaiting")
	end
end

function ArenaControllerScript:OnUserLeaveGame(user)
	for i, paddle in ipairs(self.paddles) do 
		if paddle:FindScriptProperty("user") == user then 
			self:EliminatePlayer(paddle.playerPaddleScript)
		end
	end
	
	user:SendToScripts("DoOnLocal", self:GetEntity(), "HideWinner")
end

return ArenaControllerScript
