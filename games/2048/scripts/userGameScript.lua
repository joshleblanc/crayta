local UserGameScript = {}

-- Script properties are defined here
UserGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onUpdate", type = "event" },
	{ name = "onMove", type = "event" },
	{ name = "onSpawn", type = "event" },
	{ name = "onStart", type = "event" },
	{ name = "onStop", type = "event" },
}

function UserGameScript:Init()
	self:GetEntity():GetLeaderboardValue("best-score-all-time", function(score, rank)
		self:SendToLocal("UpdateHighscore", score)
	end)
	
	self:GetEntity():GetLeaderboardValue("highest-combo-all-time", function(score, rank)
		self:SendToLocal("UpdateBestCombo", score)
	end)
end

function UserGameScript:UpdateBestCombo(score)
	self.bestCombo = score
	self:GetEntity().userScoreWidget.js.data.bestCombo = score
end

function UserGameScript:UpdateHighscore(score)
	self.bestScore = score
	self:GetEntity().userScoreWidget.js.data.bestScore = score
end

function UserGameScript:LocalInit()
	self.widget = self:GetEntity().userScoreWidget
	self.widget.js.data.inGame = true
	self.widget.js.data.inResults = false
	self.widget.js.data.prompt = Text.Format("Press {extra1-icon-raw} to exit to menu")
	self.widget:Hide()
end

function UserGameScript:Start()
	self.board = { { 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { 0, 0, 0 , 0}, { 0, 0, 0, 0 } }
	self.numFilled = 0
	self.score = 0
	self.combo = 0
	self:SpawnRandom()
	self:PrintBoard()
	self.widget.js.data.score = 0
	self.running = true
	self.properties.onStart:Send(self.board)
	self.widget.js.data.inResults = false
	self.widget.js.data.inGame = true
	self.widget:Show()
	self:GetEntity():SendToScripts("DisableCursor")
end

function UserGameScript:PlayAgain()
	self:Start()
end

function UserGameScript:GoToMenu()
	self:Stop()
end

function UserGameScript:SpawnRandom()
	local col = math.random(1, 4)
	local row = math.random(1, 4)

	if self.board[row][col] > 0 then
		self:SpawnRandom()
	else
		self.numFilled = self.numFilled + 1
		self.board[row][col] = 2
		self.properties.onSpawn:Send(row, col)
	end
end

function UserGameScript:SaveCombo(num)
	if not IsServer() then
		self:SendToServer("SaveCombo", num)
		return
	end
	
	self:GetEntity():SetLeaderboardValue("highest-combo-weekly", num)
	self:GetEntity():SetLeaderboardValue("highest-combo-all-time", num)
	self:GetEntity():SendXPEvent("combine", { num = num })
end

function UserGameScript:SaveScore(score)
	if not IsServer() then
		self:SendToServer("SaveScore", score)
		return
	end
	
	self:GetEntity():SetLeaderboardValue("best-score-weekly", score)
	self:GetEntity():SetLeaderboardValue("best-score-all-time", score)
end

function UserGameScript:SendScoreXp(score)
	if not IsServer() then
		self:SendToServer("SendScoreXp", score)
		return
	end
	self:GetEntity():SendXPEvent("score", { score = score })
end

function UserGameScript:AdjustRow(axis, row, direction, t)
	local index, top, bot, inc
	if direction == "forward" then
		index = 4
		top = 4
		bot = 1
		inc = -1
	else
		index = 1
		top = 1
		bot = 4
		inc = 1
	end
	for i=top,bot,inc do
		if t[i] > 0 then
			if i ~= index then
				-- If we have a match
				if t[i] == t[index] then
					local newValue = t[index] * 2
					self.properties.onMove:Send({
						axis = axis,
						row = row, 
						col = i,
						direction = direction, 
						newCol = index,
						prevValue = t[i],
						newValue = newValue
					})
					
					self:GetEntity():SendToScripts("AddXp", newValue)
					self.score = self.score + newValue
					self:SaveScore(self.score)
					self.widget.js.data.score = self.score
					
					if self.score > self.bestScore then
						self:UpdateHighscore(self.score)
					end
					
					if newValue > self.combo then 
						self:SaveCombo(newValue)
						self.combo = newValue
					end
					
					if self.combo > self.bestCombo then
						self:UpdateBestCombo(self.combo)
					end

					self:SendScoreXp(newValue)
					
					t[index] = newValue
					t[i] = 0
					index = math.clamp(index + inc, 1, 4)
				-- If there's no block here
				elseif t[index] == 0 then
					self.properties.onMove:Send({
						axis = axis,
						row = row, 
						col = i,
						newCol = index,
						direction = direction, 
						prevValue = t[i],
						newValue = t[i]
					})
					t[index] = t[i]
					t[i] = 0
				-- Otherwise, there's a block that we can't merge with
				else
					index = math.clamp(index + inc, 1, 4)
					self.properties.onMove:Send({
						axis = axis,
						row = row, 
						col = i,
						newCol = index,
						direction = direction, 
						prevValue = t[i],
						newValue = t[i]
					})
					t[index] = t[i]
					if i ~= index then
						t[i] = 0
					end
				end
			end
		end
	end
	return t
end

function UserGameScript:LocalOnButtonPressed(btn)
	if not self.running then return end
	
	local tableBefore = {}
	for _, v in ipairs(self.board) do
		table.insert(tableBefore, { unpack(v) })
	end

	if btn == "right" then
		for i=1,4 do 
			self.board[i] = self:AdjustRow("row", i, "forward", { 
				self.board[i][1],  
				self.board[i][2],
				self.board[i][3],
				self.board[i][4]
			})
		end
	end
	
	if btn == "left" then
		for i=1,4 do
			self.board[i] = self:AdjustRow("row", i, "backward", { 
				self.board[i][1],  
				self.board[i][2],
				self.board[i][3],
				self.board[i][4]
			})
			
		end
	end
	
	if btn == "forward" then
		for i=1,4 do
			local res = self:AdjustRow("col", i, "forward", {
				self.board[1][i],
				self.board[2][i],
				self.board[3][i],
				self.board[4][i]
			})
			self.board[1][i] = res[1]
			self.board[2][i] = res[2]
			self.board[3][i] = res[3]
			self.board[4][i] = res[4]
		end
	end
	
	if btn == "backward" then
		for i=1,4 do
			local res = self:AdjustRow("col", i, "backward", {
				self.board[1][i],
				self.board[2][i],
				self.board[3][i],
				self.board[4][i]
			})
			self.board[1][i] = res[1]
			self.board[2][i] = res[2]
			self.board[3][i] = res[3]
			self.board[4][i] = res[4]
		end
	end
	
	if btn == "extra1" then
		self.running = false
		self:GetEntity():SendToScripts("LocalConfirm", "Are you sure you want to exit?", function(result)
			self.running = true
			if result then
				self:Stop()
			end
		end)
	end
	
	if not self:CompareTables(tableBefore, self.board) then
		self:SpawnRandom()
		--self:PrintBoard()
		self.properties.onUpdate:Send(self.board)
	end
	
	if self:BoardFull() then
		if self:IsGameOver() then
			self:EndGame()
		end
	end
end

function UserGameScript:EndGame()
	print("No more moves")
	self.running = false
	self.widget.js.data.inGame = false
	self.widget.js.data.inResults = true
	self:GetEntity():SendToScripts("EnableCursor")
end

function UserGameScript:IsGameOver()
	for i=2,3 do
		for j=1,4 do
			local comp = self.board[i][j]
			if comp == self.board[i + 1][j] then
				return false
			end
			if comp == self.board[i - 1][j] then
				return false
			end
		end
	end
	for i=2,3 do 
		for j=1,4 do
			local comp = self.board[j][i]
			if self.board[j][i + 1] == comp then
				return false
			end
			if self.board[j][i - 1] == comp then
				return false
			end
		end
	end
	return true
end

function UserGameScript:BoardFull()
	for i=1,4 do 
		for j=1,4 do
			if self.board[i][j] == 0 then
				return false
			end
		end
	end
	return true
end

function UserGameScript:Stop()
	self.properties.onStop:Send()
	self:GetEntity().userMenuScript:Show()
	self.widget:Hide()
	self.running = false
end

function UserGameScript:CompareTables(a, b)
	for i=1,4 do
		for j=1,4 do
			if a[i][j] ~= b[i][j] then
				return false
			end
		end
	end
	return true
end

function UserGameScript:PrintBoard()
	for i=1,4 do
		local line = ""
		for j=1,4 do
			line = line .. self.board[i][j]
		end
		print(line)
	end
	print("----")
end

return UserGameScript
