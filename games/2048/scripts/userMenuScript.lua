local UserMenuScript = {}

-- Script properties are defined here
UserMenuScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "grid", type = "entity" },
	{ name = "music", type = "soundasset" }
}

--This function is called on the server when this entity is created
function UserMenuScript:Init()
end

function UserMenuScript:LocalInit()
	self.widget = self:GetEntity().userMenuWidget
	self.widget.js.data.avatarUrl = self:GetEntity():GetPlayerCardIcon()
	self.sets = self:GetEntity():FindAllScripts("setScript")
	print("Num sets", #self.sets)

	self:GetEntity().saveDataScript.properties.onSaveDataReady:Listen(self, "UpdateSets")

	self:Show()
end

function UserMenuScript:UpdateSets()
	if IsServer() then
		self:SendToLocal("UpdateSets")
		return
	end
	
	local sets = {}
	for _, set in ipairs(self.sets) do	
		if set:IsSelected() then
			self.properties.grid:SendToScripts("SetArena", set)
		end
		
		if #sets == 0 then
			table.insert(sets, set:ToTable())
		else
			local indexToInsert = #sets + 1
			for i=1,#sets do 
				if set.properties.unlockLevel > sets[i].unlockLevel then
					indexToInsert = i + 1
				end
			end
			table.insert(sets, indexToInsert, set:ToTable())
		end
	end
	self.widget.js.data.sets = sets
end

function UserMenuScript:MenuSelectSet(id) 
	print("Selecting single set")
	local set 
	for i=1,#self.sets do
		if self.sets[i].properties.id == id then
			set = self.sets[i]
			set:SelectSet()
		else
			self.sets[i]:DeselectSet()
		end
	end
	self:UpdateSets()
	--self.properties.grid:SendToScripts("SetArena", set)
end

function UserMenuScript:FindSet(id)
	
	return nil
end

function UserMenuScript:Show()
	self.soundHandle = self:GetEntity():PlaySound2D(self.properties.music)
	print(self:GetEntity().userStatScript:GetLevelPercent() * 100)
	self.widget.js.data.xpPercent = FormatString("{1}%", self:GetEntity().userStatScript:GetLevelPercent() * 100)
	self.widget.js.data.level = self:GetEntity().userStatScript:Level()
	self.widget.js.data.username = tostring(self:GetEntity():GetUsername())
	print("level percent", self:GetEntity().userStatScript:GetLevelPercent())
	self.widget:Show()
	self:SendToServer("UpdateHighscores")
	
	local challenges = {}
	local challengesCompleted = 0
	for _, v in pairs(GetWorld():GetActiveChallenges()) do
		local data = v
		data.progress = self:GetEntity():GetChallengeProgress(data.id)
		if data.progress == data.count then
			challengesCompleted = challengesCompleted + 1
		end
		table.insert(challenges, data)
	end
	self.widget.js.data.totalChallenges = #challenges
	self.widget.js.data.challengesCompleted = challengesCompleted
	self.widget.js.data.challenges = challenges
	
	self:UpdateLeaderboards()
end

function UserMenuScript:UpdateLeaderboards()
	Leaderboards.GetTopValues("best-score-all-time", 10, function(data)
		self.widget.js.data.topScores = data
	end)
	
	Leaderboards.GetTopValues("best-score-weekly", 10, function(data)
		self.widget.js.data.weeklyScores = data
	end)
	
	self:GetEntity():GetLeaderboardValue("best-score-weekly", function(score, rank)
		self.widget.js.data.youWeekly = { score = score, rank = rank }
	end)
	
	self:GetEntity():GetLeaderboardValue("best-score-all-time", function(score, rank)
		self.widget.js.data.highscore = score
		self.widget.js.data.youAllTime = { score = score, rank = rank }
	end)
	
	self:GetEntity():GetLeaderboardValue("highest-combo-all-time", function(score, rank)
		self.widget.js.data.bestCombo = score
	end)
end

function UserMenuScript:DoAction(what)
	if what == "play" then
		self:GetEntity():StopSound(self.soundHandle)
		self.widget:Hide()
		self:GetEntity().userGameScript:Start()
	end
end

return UserMenuScript
