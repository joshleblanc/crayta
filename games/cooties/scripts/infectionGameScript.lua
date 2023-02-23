local InfectionGameScript = {}

-- Script properties are defined here
InfectionGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function InfectionGameScript:Init()
end

function InfectionGameScript:HandleRoundStart(gameScript)
	self.gameScript = gameScript
	
	local users = GetWorld():GetUsers()
	local infected = users[math.random(1, #users)]
	
	infected:SendToScripts("Infect")
	
	self.infectionTask = self:Schedule(
		function()
			while true do
				Wait(1.0)
				self:CheckForSurvivors()
			end
		end
	)
end

function InfectionGameScript:HandleRoundEnd()
	if self.infectionTask then
		self:Cancel(self.infectionTask)
		self.infectionTask = nil
	end
end

function InfectionGameScript:CheckForSurvivors()
	-- count alive teams or alive users depending on if team game
	local numSurvivors = 0
	GetWorld():ForEachUser(
		function(userEntity)
			if userEntity:FindScriptProperty("team") == 1 then 
				numSurvivors = numSurvivors + 1
			end
		end
	)
	
	if numSurvivors < 1 then
		Print("Infection: Ending as no survivors left")
		self.gameScript:EndPlay()
	end
end

function InfectionGameScript:TeamHasPlayers(teamIndex)
	local found = false
	GetWorld():ForEachUser(
		function(userEntity)
			if userEntity:FindScriptProperty("team") == teamIndex then
				found = true
			end
		end
	)
	return found
end

function InfectionGameScript:GetResults(results)

	Print("Infection: Getting winner")

	-- store a table of each user and their score
	results.userEntries = {}
	GetWorld():ForEachUser(
		function(userEntity)
			table.insert(results.userEntries, {
				user = userEntity, 
				score = userEntity:FindScriptProperty("score") or 0,
			})
		end
	)
	
	results.teamEntries = {}
	local teamsUnsorted = {}
	
	local team = {
		name = self.gameScript.teamNames[1], 
		color = self.gameScript.teamColors[1],
		score = self.gameScript.teamScores[1],
		rank = self:TeamHasPlayers(1) and 1 or 2,
	}
	table.insert(results.teamEntries, team)
	table.insert(teamsUnsorted, team)
	
	team = {
		name = self.gameScript.teamNames[2], 
		color = self.gameScript.teamColors[2],
		score = self.gameScript.teamScores[2],
		rank = self:TeamHasPlayers(1) and 2 or 1,
	}
	table.insert(results.teamEntries, team)
	table.insert(teamsUnsorted, team)

	
	table.sort(results.teamEntries, function(u1, u2) return u1.rank < u2.rank end)

	for _, userEntry in ipairs(results.userEntries) do
		userEntry.rank = teamsUnsorted[userEntry.user:FindScriptProperty("team")].rank
	end
		
	table.sort(results.userEntries, function(u1, u2) return u1.rank < u2.rank end)
	
end


return InfectionGameScript
