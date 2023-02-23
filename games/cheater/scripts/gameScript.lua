GameScript = {}

function VisibleIfTeams(properties) 
	return properties.hasTeams 
end

-- Here are all of the Properties that are exposed to the Property window in the editor
GameScript.Properties = { 
	{ name = "welcomeMsg", type = "text", },
	{ name = "playerJoinedMsg", type = "text", },
	{ name = "playerLeftMsg", type = "text", },
	{ name = "alwaysDoLobby", type = "boolean", default = false, tooltip = "If set then the lobby will always be shown between rounds"},
	{ name = "maxLobbyTime", type = "number", default = 10, editor = "seconds", tooltip = "Set this to zero to just get on with round"},
	{ name = "minPlayersToPlay", type = "number", default = 1, allowFloatingPoint = false, tooltip = "Some games require more than one player to end the lobby phase"},
	{ name = "maxPlayTime", type = "number", default = 60, editor = "seconds", tooltip = "Set this to zero for round to last until EndPlay is called" },
	{ name = "killScore", type = "number", allowFloatingPoint = false, default = 1, },
	{ name = "hasTeams", type = "boolean", default = true, },
	{ name = "teamKillScore", type = "number", allowFloatingPoint = false, default = 1, visibleIf = VisibleIfTeams, },
	{ name = "teamNameBlue", type = "text", visibleIf = VisibleIfTeams, },
	{ name = "teamNameRed", type = "text", visibleIf = VisibleIfTeams, },
	{ name = "autoRespawn", type = "boolean", default = true, },
	{ name = "alwaysRespawnForPlay", type = "boolean", default = true, tooltip = "If you set this to false, the player will not respawn at start of play state if a player already exists from the lobby. You should leave this true if using different spawn points for lobby and play" },
	{ name = "allowMidGameJoin", type = "boolean", default = true, },
	{ name = "maxResultsTime", type = "number", default = 10, editor = "seconds", },
	{ name = "resultsCamera", type = "entity", },
	{ name = "onUserDied", type = "event", },
	{ name = "onLobbyStart", type = "event", },
	{ name = "onLobbyEnd", type = "event", },
	{ name = "onRoundStart", type = "event", },
	{ name = "onRoundEnd", type = "event", },
	{ name = "onResultsStart", type = "event", },
	{ name = "onResultsEnd", type = "event", },
	{ name = "roundIndex", type = "number", editable = false, },
}

-- This Init() function is called when the entity this script is attached to is created
function GameScript:Init()
	
	if self.properties.hasTeams then
		self.teamScores = {0, 0}
		self.teamNames = {self.properties.teamNameBlue, self.properties.teamNameRed}
		self.teamColors = {"blue", "red"}
	end
	
	self.properties.roundIndex = 0
	
	-- Here we schedule our game loop to run in a separate thread
	self:Schedule(
		function()
			
			-- wait for at least one player to be initialised before starting the game loop
			while #self:GetUsers() == 0 or not self:GetUsers()[1]:IsLocalReady() do
				Print("Game: Waiting for a user...") -- print out a message to the console
				Wait(1.0) -- this function pauses the thread for a given amount of time, in this case 1 second
			end

			-- main game loop
			while true do
				-- only do lobby first iteration or if not enough players
				if (self.properties.roundIndex == 0 or #self:GetUsers() < self.properties.minPlayersToPlay or self.properties.alwaysDoLobby) then
					self:DoLobbySchedule()
				end
				self:DoPlaySchedule() -- trigger the play schedule to run
				self:DoResultsSchedule() -- trigger the results schedule to run
				self.properties.roundIndex = self.properties.roundIndex + 1 -- at the end of the loop increase the roundIndex variable
			end
		end
	)
	
end

function GameScript:ForEachUser(fn, ...)
	for _, user in ipairs(self:GetUsers()) do 
		fn(user, ...)
	end
end

function GameScript:GetUsers()
	local users = {}
	GetWorld():ForEachUser(function(user)
		if user:FindScriptProperty("inGame") then
			table.insert(users, user)
		end
	end)
	
	return users
end

-- This is our lobby loop running within the main game loop Schedule
function GameScript:DoLobbySchedule()

	-- start
	self.properties.onLobbyStart:Send(self)
	
	local enoughPlayers = false
	while not enoughPlayers do
	
		-- start wait for players 		
		Print("Game: Waiting for players...")

		self.newUserCallback = function(userEntity)
			self:CallUserEvent(userEntity, "onLobbyStart", {
				spawn = true, 
				isLobby = true, 
				alwaysRespawn = true, 
				respawnActive = true, 
				morePlayers = true, 
			})
		end
		self:ForEachUser(self.newUserCallback)

		-- wait until we have enough players		
		while not enoughPlayers do
			enoughPlayers = #self:GetUsers() >= self.properties.minPlayersToPlay
			Wait(1.0)
		end	
		
		-- start a round start timer now we have enough players
		Print("Game: Waiting for timer...")
		local stateStartTime = GetWorld():GetServerTime()
		self.newUserCallback = function(userEntity)
			self:CallUserEvent(userEntity, "onLobbyStart", {
				spawn = true, 
				isLobby = true, 
				respawnActive = true, 
				startTime = stateStartTime, 
				totalTime = self.properties.maxLobbyTime
			})
		end
		self:ForEachUser(self.newUserCallback)

		-- while timer is running check to see if people have left the game meaning we need to wait again
		while GetWorld():GetServerTime() < stateStartTime + self.properties.maxLobbyTime do
			-- recalculate if enough players to start in case people drop out of lobby
			enoughPlayers = #self:GetUsers() >= self.properties.minPlayersToPlay
			if not enoughPlayers then
				break
			end
			Wait(1.0)
		end

	end

	-- end
	
	self.properties.onLobbyEnd:Send(self)
	
	-- loop through all of the users in the game and send a requst to call an 'OnLobbyEnd' function on the scripts attached to them
	self:ForEachUser(
		function(userEntity)
			self:CallUserEvent(userEntity, "onLobbyEnd")
		end
	)
	
end

-- Our play schedule for the round logic 
function GameScript:DoPlaySchedule()
	
	print("Starting round")
	-- start

	local stateStartTime = GetWorld():GetServerTime()
	if self.properties.hasTeams then
		self.teamScores = {0, 0}
	end

	
	self.newUserCallback = function(userEntity, startOfGameState)
		print(startOfGameState, self.properties.allowMidGameJoin)
		-- send to user
		self:CallUserEvent(userEntity, "onRoundStart", {
			startTime = stateStartTime, 
			totalTime = self.properties.maxPlayTime, 
			teamNames = self.teamNames, 
			teamColors = self.teamColors, 
			teamScores = self.teamScores,
			spawn = startOfGameState or self.properties.allowMidGameJoin, 
			alwaysRespawn = self.properties.alwaysRespawnForPlay,
			isLobby = false, 
			respawnActive = self.properties.autoRespawn, 
		})
		
	end
	
	
	-- Send analytics event
	local matchHandle = Analytics.MatchStarted()
	
	-- set a flag to show we're calling newUserCallback at start of game,
	-- so we'll always spawn players there. Other players who join during
	-- play will get newUserCallback called for them also but the flag 
	-- won't be set so they might choose not to spawn a player (allowMidGameJoin)
	print("calling new user callback")
	self:ForEachUser(self.newUserCallback, true)
	
		-- send global event
	self.properties.onRoundStart:Send(self)

	
	-- wait until time (if maxPlayTime is set to 0 this will be forever and rely on someone calling EndPlay)
	self.endTime = (self.properties.maxPlayTime > 0) and (stateStartTime + self.properties.maxPlayTime) or math.huge
	while GetWorld():GetServerTime() < self.endTime and #self:GetUsers() >= self.properties.minPlayersToPlay do
		Wait(1.0)
	end

	-- we create a table called results, this is passed to any other
	-- scripts on the game entity for filling in GetResults
	-- which can fill in an entries array within it
	-- if nothing is listening to this and fills it in then we just
	-- go off basic team or individual scores from CalcScores()
	self.results = {}
	self:GetEntity():SendToScripts("GetResults", self.results)
	if self.results.userEntries == nil then
		self:GetResultsBasic(self.results)
	end
	
	-- if team event then display highest team
	Printf("Game: User Results")
	for index, userEntry in ipairs(self.results.userEntries) do
		Printf("  {1}: {2} score = {3}", userEntry.rank, userEntry.user:GetUsername(), userEntry.score)
	end
	if self.results.teamEntries then
		Print("Game: Team Results")
		for index, teamEntry in ipairs(self.results.teamEntries) do
			Printf("  {1}: {2} score = {3}", teamEntry.rank, teamEntry.name, teamEntry.score)
		end
	end
	
	-- end
	Analytics.MatchEnded(matchHandle, self.results.userEntries)

	-- send challenge events
	for _, userEntry in ipairs(self.results.userEntries) do
		userEntry.user:SendXPEvent("match-end", {score = userEntry.score, rank = userEntry.rank, numPlayers = #self.results.userEntries})
	end

	-- send a traditional event
	self.properties.onRoundEnd:Send(self)
	self:ForEachUser(
		function(userEntity)
			self:CallUserEvent(userEntity, "onRoundEnd")
		end
	)
end

-- simple function to score based on either team or individual scores, for more complex game modes (survival rules, etc)
-- implement a script on the game entity which has a GetResults function similar to this one that fills in the entries
function GameScript:GetResultsBasic(results)

	-- utility function to assign ranks from 1 upwards
	-- depending on score, assuming pre-sorted array
	local assignRank = function(array) 
		-- sort by score
		table.sort(array, function(e1, e2) return e1.score > e2.score end)
		local rank = 1
		local lastEntry = nil
		for index, entry in ipairs(array) do 
			-- if we're on the second or later entry then we up rank if our score isn't same as previous (otherwise we give same rank) 
			if lastEntry and entry.score < lastEntry.score then
				rank = rank + 1
			end
			entry.rank = rank
			lastEntry = entry
		end
	end
	
	-- store a table of each user and their score
	results.userEntries = {}
	self:ForEachUser(
		function(userEntity)
			table.insert(results.userEntries, {
				user = userEntity, 
				score = userEntity:FindScriptProperty("score") or 0,
			})
		end
	)
	
	-- if a team game then also store teams and sort on that
	-- we then apply rank to users based on their team
	if self.properties.hasTeams then
	
		results.teamEntries = {}
		local teamsUnsorted = {}
		for teamIndex = 1, #self.teamScores do
			local team = {
				name = self.teamNames[teamIndex], 
				color = self.teamColors[teamIndex],
				score = self.teamScores[teamIndex],
			}
			table.insert(results.teamEntries, team)
			table.insert(teamsUnsorted, team)
		end
		
		-- assign rank 1 to highest team, 2 to next, etc...
		assignRank(results.teamEntries)
		
		-- now copy the rank from the team each user is in into the user's rank
		-- and sort the users by rank (with lowest being higher up table)
		for _, userEntry in ipairs(results.userEntries) do
			userEntry.rank = teamsUnsorted[userEntry.user:FindScriptProperty("team")].rank
		end
		table.sort(results.userEntries, function(u1, u2) return u1.rank < u2.rank end)
		
	else
	
		-- otherwise in a non team game we apply rank based on individual scores
		assignRank(results.userEntries)
	
	end
	
end	


-- can be called from other scripts in, for example, a survival game when the last player is alive...
function GameScript:EndPlay(time)
	-- if more than a certain amount of time left then end it early
	self.endTime = math.min(self.endTime, GetWorld():GetServerTime() + (time or 0))
end

-- our results schedule run in the main game loop
function GameScript:DoResultsSchedule()
	-- start 

	local stateStartTime = GetWorld():GetServerTime()
	self.properties.onResultsStart:Send(self)
	
	self.newUserCallback = function(userEntity)
	
		self:CallUserEvent(userEntity, "onResultsStart", {
			startTime = stateStartTime, 
			totalTime = self.properties.maxResultsTime, 
			results = self.results,
			camera = self.properties.resultsCamera,
		})
	end
	self:ForEachUser(self.newUserCallback)

	-- wait
	
	while GetWorld():GetServerTime() < stateStartTime + self.properties.maxResultsTime and #self:GetUsers() >= self.properties.minPlayersToPlay  do
		Wait(1.0)
	end

	-- end
	
	self.properties.onResultsEnd:Send(self)
	self:ForEachUser(
		function(userEntity)
			self:CallUserEvent(userEntity, "onResultsEnd")
		end
	)
end

function GameScript:CallUserEvent(userEntity, eventName, ...)
	local gameUserScript = userEntity.gameUserScript
	if gameUserScript then
		userEntity.gameUserScript.properties[eventName]:Send(...)
	end
end

function GameScript:HandleUserJoin(userEntity)
	Printf("Game: User {1} logged in as {2}", userEntity:GetUsername(), userEntity:GetName())

	-- send to all except the one who just logged in...
	self:ForEachUser(
		function(testUserEntity) 
			if testUserEntity ~= userEntity then 
				testUserEntity:SendToLocal("AddNotification", self.properties.playerJoinedMsg, {name = userEntity:GetUsername()})
			end 
		end
	)
	
	if self.properties.hasTeams then
		self:SetUserTeam(userEntity)
	end
	
	-- send a welcome
	userEntity:SendToLocal("AddNotification", self.properties.welcomeMsg, {name = userEntity:GetUsername()})
	if self.newUserCallback then	
		print("Calling from onuserlogin")
		self.newUserCallback(userEntity)
	end
end

-- When a user connects to the game this function is called automatically
function GameScript:OnUserLogin(userEntity)
	-- we assume every user using the game script has a spawnUserScript here
	userEntity.spawnUserScript.properties.onUserDied:Listen(self, "OnUserDied")
end

function GameScript:HandleUserLeave(userEntity)
	-- send to all except the one who just logged out...
	self:ForEachUser(
		function(testUserEntity) 
			if testUserEntity ~= userEntity then 
				testUserEntity:SendToLocal("AddNotification", self.properties.playerLeftMsg, {name = userEntity:GetUsername()})
			end 
		end
	)
end

function GameScript:OnUserLogout(userEntity)	
	self:HandleUserLeave(userEntity)
end

function GameScript:SetUserTeam(userEntity)

	-- find team with smallest number of members
	local teamCounts = {0, 0}
	self:ForEachUser(
		function(testUser)
			if testUser ~= userEntity then
				local teamIndex = testUser:FindScriptProperty("team")
				teamCounts[teamIndex] = teamCounts[teamIndex] + 1
			end
		end
	)
	local team = (teamCounts[1] <= teamCounts[2]) and 1 or 2
	Printf("Game: Putting new user on team {1}", team)
	
	-- this also sets voice channel (we could not set voice channel if
	-- we wanted all players to talk together)
	userEntity:SendToScripts("SetTeam", team, true)
end

function GameScript:AddTeamScore(team, num)
	
	if self.properties.hasTeams and team ~= nil and team ~= 0 then
	
		-- add to the team score
		self.teamScores[team] = self.teamScores[team] + (num or 1)
		
		-- tell all the users' scoreboards about the new score
		self:ForEachUser(
			function(userEntity)
				if userEntity.scoreboardScript then
					userEntity.scoreboardScript:AddOrUpdateTeam(team, self.teamNames[team], self.teamColors[team], self.teamScores[team])
				end
			end
		)
	end
end

function GameScript:OnUserDied(userEntity, fromEntity, selfMsg, otherMsg, youKilledMsg)
	
	-- send game event to anyone who wanted
	self.properties.onUserDied:Send(userEntity, fromEntity, selfMsg, otherMsg, youKilledMsg)

	-- find user for player who killed us (if there is one)
	local fromUser = (fromEntity and fromEntity:IsA(Character)) and fromEntity:GetUser() or nil

	-- add score
	if fromUser then
		fromUser:SendToScripts("AddScore", self.properties.killScore)
		if self.properties.hasTeams and self.properties.teamKillScore > 0 then
			self:AddTeamScore(fromUser:FindScriptProperty("team"), self.properties.teamKillScore)
		end
	end
	
end

return GameScript
