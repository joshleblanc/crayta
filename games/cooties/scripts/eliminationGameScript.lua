local EliminationGameScript = {}

EliminationGameScript.Properties = {
	{ name = "earlyEndTime", type = "number", editor = "seconds", default = 5, },
}

function EliminationGameScript:Init()
end

function EliminationGameScript:StartElimintation(gameScript)
	self.gameScript = gameScript
	self.eliminationTask = self:Schedule(
		function()
			while true do
				Wait(1.0)
				self:CheckForElimination()
			end
		end
	)
end

function EliminationGameScript:EndElimination()
	if self.eliminationTask then
		self:Cancel(self.eliminationTask)
		self.eliminationTask = nil
	end
end

function EliminationGameScript:CheckForElimination()
	
	-- count alive teams or alive users depending on if team game
	local numAlive = 0
	if self.gameScript.properties.hasTeams then

		for teamIndex = 1, #self.gameScript.teamScores do
			if self:TeamHasAlivePlayers(teamIndex) then
				numAlive = numAlive + 1
			end
		end
	
	else
	
		GetWorld():ForEachUser(
			function(userEntity)
				if userEntity:GetPlayer() and userEntity:GetPlayer():IsAlive() then
					numAlive = numAlive + 1
				end
			end
		)
	
	end
	
	if numAlive <= 1 then
		Print("Elimination: Ending as one player/team left")
		self.gameScript:EndPlay(self.properties.earlyEndTime)
		self:EndElimination()
	end
	
end

function EliminationGameScript:TeamHasAlivePlayers(teamIndex)

	local found = false
	GetWorld():ForEachUser(
		function(userEntity)
			if userEntity:GetPlayer() and userEntity:GetPlayer():IsAlive() and userEntity:FindScriptProperty("team") == teamIndex then
				found = true
			end
		end
	)
	return found
end

function EliminationGameScript:GetResults(results)

	Print("Elimination: Getting winner")

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
	
	if self.gameScript.properties.hasTeams then
	
		results.teamEntries = {}
		local teamsUnsorted = {}
		for teamIndex = 1, #self.gameScript.teamScores do
			local team = {
				name = self.gameScript.teamNames[teamIndex], 
				color = self.gameScript.teamColors[teamIndex],
				score = self.gameScript.teamScores[teamIndex],
				rank = self:TeamHasAlivePlayers(teamIndex) and 1 or 2,
			}
			table.insert(results.teamEntries, team)
			table.insert(teamsUnsorted, team)
		end
		
		table.sort(results.teamEntries, function(u1, u2) return u1.rank < u2.rank end)

		for _, userEntry in ipairs(results.userEntries) do
			userEntry.rank = teamsUnsorted[userEntry.user:FindScriptProperty("team")].rank
		end
		
	else
	
		for _, userEntry in ipairs(results.userEntries) do
			userEntry.rank = (userEntry.user:GetPlayer() and userEntry.user:GetPlayer():IsAlive()) and 1 or 2
		end
	
	end
	
	table.sort(results.userEntries, function(u1, u2) return u1.rank < u2.rank end)
	
end

return EliminationGameScript
