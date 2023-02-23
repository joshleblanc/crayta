local GameScript = {}

-- Script properties are defined here
GameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "wealthRequired", type = "number" },
	{ name = "team1WinCamera", type = "entity" },
	{ name = "team2WinCamera", type = "entity" },
	{ name = "tower1", type = "entity" },
	{ name = "tower2", type = "entity" }
}

--This function is called on the server when this entity is created
function GameScript:Init()
	self.team1 = {
		wood = 0,
		stone = 0,
		gold = 0
	}
	
	self.team2 = {
		wood = 0,
		stone = 0,
		gold = 0
	}
	
	self.numLayers = self.properties.tower1.resourceStackScript:NumLayers()
	self.breakpoint = self.properties.wealthRequired / self.numLayers
end

function GameScript:ShowLayer(tower, total)
	local layer = math.ceil(total / self.breakpoint)
	tower:SendToScripts("Show", layer)
end

function GameScript:HandleStorageUpdate(key, value)
	local teams = { 1, 2 }
	local resources = { "gold", "wood", "stone" }
	
	for _, team in ipairs(teams) do
		for _, resource in ipairs(resources) do
			if FormatString("{1}-{2}", team, resource) == key then
				self["team" .. team][resource] = value
			end
		end
	end
	
	local totals = {
		self.team1.gold + self.team1.stone + self.team1.wood,
		self.team2.gold + self.team2.stone + self.team2.wood
	}
	
	self:ShowLayer(self.properties.tower1, totals[1])
	self:ShowLayer(self.properties.tower2, totals[2])
	
	local gameOver = false

	if totals[1] >= self.properties.wealthRequired then
		gameOver = true
		GameStorage.UpdateCounter("1-wins", 1)
		GetWorld():ForEachUser(function(user)
			user:SetCamera(self.properties.team1WinCamera, 1)
			user:SendToScripts("ShowTeam1Win")
		end)
	end
	
	if totals[2] >= self.properties.wealthRequired then
		gameOver = true
		GameStorage.UpdateCounter("2-wins", 1)
		GetWorld():ForEachUser(function(user)
			user:SetCamera(self.properties.team2WinCamera, 1)
			user:SendToScripts("ShowTeam2Win")
		end)
	end
	
	if gameOver then
		for _, team in ipairs(teams) do
			for _, resource in ipairs(resources) do
				GameStorage.GetCounter(FormatString("{1}-{2}", team, resource), function(val)
					GameStorage.UpdateCounter(FormatString("{1}-{2}", team, resource), -val)
				end)
			end
		end
	end
end

return GameScript
