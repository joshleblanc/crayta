local StatsScript = {}

-- Script properties are defined here
StatsScript.Properties = {
	{ name = "onStatChange", type = "event" },
	{ name = "onStatLevelUp", type = "event" },
}

function StatsScript:Init()
	local sum = 0
	for id, stat in pairs(self:GetStats()) do 
		if id ~= "level" then 
			sum = sum + stat.properties.baseLevel
		end
	end
	
	print(self:GetEntity().monsterScript.properties.name, sum)
end

function StatsScript:SeedIvs()
	for id, stat in pairs(self:GetStats()) do 
		stat:SeedIv()
	end

end

function StatsScript:ComputeXpForLinkedStats()
	for id, stat in pairs(self:GetStats()) do 
		stat:ComputeXpForLinkedStat()
	end
end

function StatsScript:StatName(id)
	return self:GetStats()[id].properties.name
end

function StatsScript:GetStat(id)
	return self:GetStats()[id]
end

-- Prefer this function over self.stats
-- There are load-order issues where self.stats 
-- may not be initialized yet
-- this method initializes the stats before use, if they're
-- not initialized yet
function StatsScript:GetStats()
	if not self.stats then
		self:InitStats()
	end
	return self.stats
end

function StatsScript:InitStats()
	self.stats = {}
	
	local stats = self:GetEntity():FindAllScripts("statScript")
	for i=1,#stats do 
		local stat = stats[i]
		self.stats[stat.properties.id] = stat
	end
	
	return self.stats
end

function StatsScript:Sum()
	local sum = 0
	for _,v in pairs(self:GetStats()) do
		sum = sum + v:Level()
	end
	return sum
end

function StatsScript:LevelUp(id)
	local stat = self:GetStats()[id]
	
	local xpRemaining = stat:XpRemaining()
	self:AddXp(id, xpRemaining)
end

function StatsScript:SetLevel(id, level)
	local stat = self:GetStats()[id]
	
	stat.properties.xp = 0

	self:AddXp(id, stat:XpForLevel(level))
end

function StatsScript:AddXp(id, xp)
	local stat = self:GetStats()[id]

	local levelBefore = stat:Level()
	local result = stat:AddXp(xp)
	local levelAfter = stat:Level()
	if result then
		self.properties.onStatChange:Send(self:GetEntity(), id, xp, stat)
	end
	
	if levelBefore < levelAfter then 
		self.properties.onStatLevelUp:Send(self:GetEntity(), id, xp, stat)
	end
	return result
end

function StatsScript:AddEv(id, amt)
	local stat = self:GetStats()[id]
	
	stat:AddEv(amt)
end

function StatsScript:Print()
	for _, stat in pairs(self:GetStats()) do
		print(stat.properties.id, stat:Level())
	end
	print("-------------")
end

return StatsScript
