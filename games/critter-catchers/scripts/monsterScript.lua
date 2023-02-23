local MonsterScript = {}

local TYPES = { "normal", "fighting", "flying", "poison", "ground", "rock", "bug", "ghost", "steel", "fire", "water", "grass", "electric", "psychic", "ice", "dragon", "dark", "fairy" }


-- Script properties are defined here
MonsterScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" },
	{ name = "docId", type = "string", editable = false },
	{ name = "name", type = "text" },
	{ name = "types", type = "string", options = TYPES, default = "normal", container = "array" },
	{ name = "faceSprite", type = "string" },
	{ name = "fullSprite", type = "string" },
	{ name = "catchRate", type = "number", min = 0, max = 255, default = 45 },
	{ name = "index", type = "number", default = 1, editable = false },
	{ name = "hp", type = "number", editable = false },
	{ name = "isWild", type = "boolean", editable = false },
	{ name = "participating", type = "boolean", editable = false },
	{ name = "evolution", type = "template" },
	{ name = "evolutionLevel", type = "number", default = 0 },
	{ name = "accuracy", editable = false, type = "number", default = 1 },
	{ name = "evasion", editable = false, type = "number", default = 1 },
	{ name = "poisoned", type = "boolean", editable = false, default = false },
	{ name = "confused", type = "boolean", editable = false, default = false },
	{ name = "leveledUp", type = "boolean", default = false, editable = false },
	{ name = "prevLevel", type = "number", default = false, editable = false, default = 0 }
}

function MonsterScript:ClientInit()
	self.statStages = {}
end

function MonsterScript:ResetStatStages() 
	self.statStages = {}
	self.properties.poisoned = false
	self.properties.confused = false
end

function MonsterScript:InitForBattle()
	self:ResetStatStages()
	self.lastMove = nil
	self.properties.leveledUp = false
	self.properties.prevLevel = 0
	self.properties.participating = false
end

function MonsterScript:ApplyPoison()
	self.properties.poisoned = true
end

function MonsterScript:ApplyStatusEffect(effect)
	self.properties[effect] = true
end

function MonsterScript:AdjustStatStage(statId, modification)
	local before = self.statStages[statId] or 0
	local after = before + modification 
	
	self.statStages[statId] = after
	
	-- maximum of -6 or +6 status stage
	self.statStages[statId] = math.min(6, self.statStages[statId])
	self.statStages[statId] = math.max(-6, self.statStages[statId])
	
	return self.statStages[statId] - before
end

function MonsterScript:ModifyStat(statId, stat)
	local stage = self.statStages[statId] or 0
	
	local modifier = 1
	if stage < 0 then 
		modifier = 2 / (2 + math.abs(stage)) -- 2/3 2/4 2/5 2/6 2/7 2/8
	elseif stage > 0 then 
		modifier = (2 + stage) / 2 -- 3/2 4/2 5/2 6/2 7/2 8/2
	end
	
	return stat * modifier
end

function MonsterScript:IsMoveListFull()
	return self:GetNumMoves() >= 4
end

function MonsterScript:GetCache()
	if not self.cache then 
		self.cache = GetWorld():FindScript("entityCacheScript")
	end

	return self.cache
end

function MonsterScript:Evolve()
	
	if not self.properties.evolution then return end 
	
	local evolution = self:GetCache():FindEntityByTemplate(self.properties.evolution).monsterScript

	evolution:ResetHp()
	
	self:GetEntity():GetParent():SendToScripts("AddMonster", evolution, evolution.properties.hp, self:GetLevel(), self.properties.index)
	self:GetEntity():GetParent():SendToScripts("RemoveMonster", self)
	
	return evolution
end

function MonsterScript:GetStatLevel(statId)
	local stat = self:GetStat(statId)
	local level = stat:Level()
	
	return self:ModifyStat(statId, level)
end

function MonsterScript:SeedIvs()
	self:GetEntity().statsScript:SeedIvs()
end

function MonsterScript:FindMove(id)
	return self:GetMoves()[id]
end

function MonsterScript:ComputeStats()
	self:GetEntity().statsScript:ComputeXpForLinkedStats()
end

function MonsterScript:GetMoves()
	self.moves = {}
	local moves = self:GetEntity():FindAllScripts("monsterMoveScript")
	
	for _, move in ipairs(moves) do 
		self.moves[move.properties.id] = move
	end
	
	return self.moves
end

function MonsterScript:GetMovesArray()
	local moves = self:GetMoves()
	local t = {}
	
	for _, move in pairs(moves) do 
		table.insert(t, move)
	end
	
	return t
end

function MonsterScript:ApplyDamage(amt)
	self.properties.hp = math.max(0, self.properties.hp - amt)
end

function MonsterScript:Heal(amt)
	print("pre healing monster", self.properties.hp)
	self.properties.hp = math.min(self:GetMaxHp(), self.properties.hp + amt)
	print("Healing monster", amt, self:GetEntity():GetName(), self.properties.hp, self.properties.hp + amt, math.min(self:GetMaxHp(), self.properties.hp + amt), self:GetMaxHp())
end

function MonsterScript:GetStat(id)
	return self:GetEntity().statsScript:GetStat(id)
end

function MonsterScript:UpdateMoves()
	
end

function MonsterScript:AddXp(amt)
	self:GetEntity().statsScript:AddXp("level", amt)
end

function MonsterScript:AddEv(statId, amt)
	self:GetStat(statId):AddEv(amt)
end

function MonsterScript:GetHp()
	return self.properties.hp
end

function MonsterScript:GetXpReward()
	local stats = self:GetEntity().statsScript:GetStats()
	
	local sum = 0
	for id, stat in pairs(stats) do 
		if id ~= "level" then 
			sum = sum + stat.properties.baseLevel
		end
	end
	
	return math.ceil((sum * 4) / 20)
end

function MonsterScript:GetMaxHp()
	return self:GetStat("hp"):Level()
end

function MonsterScript:SetLevel(level)
	self:GetEntity().statsScript:SetLevel("level", level)
end

function MonsterScript:GetLevel()
	return self:GetEntity().statsScript:GetStat("level"):Level()
end

function MonsterScript:Load(doc)
	self.properties.hp = doc.hp
	self.properties.docId = doc._id
	self.properties.index = doc.index
	
	print("Loading monster", doc.index)
	
	if doc.moves then 
		local moves = self:GetMoves()
		
		for _, move in pairs(moves) do 
			move.properties.equipped = false
		end
		
		for _, docMove in ipairs(doc.moves) do 
			local move = self:FindMove(docMove.id)
			move:Load(docMove)
		end
	end
	
	if doc.stats then 
		for _, statDoc in ipairs(doc.stats) do 
			 self:GetEntity().statsScript:GetStat(statDoc.id):Load(statDoc)
		end
	end
	
	self:ComputeStats()
end

function MonsterScript:GetNumMoves() 
	local count = 0
	for _, move in pairs(self:GetMoves()) do
		if move.properties.equipped then 
			count = count + 1
		end
	end
	
	return count
end

function MonsterScript:ResetHp()
	self.properties.hp = self:GetMaxHp()
end

function MonsterScript:RestoreMoves()
	local moves = self:GetMoves()
	for _, move in pairs(moves) do 
		move:ResetPp()
	end
end

function MonsterScript:Heal()
	self:ResetHp()
	self:RestoreMoves()
end

function MonsterScript:ToTable()
	local moves = {}
	
	self:UpdateMoves()
	for id, move in pairs(self:GetMoves()) do 
		if move.properties.equipped then 
			table.insert(moves, move:ToTable())
		end
	end
	
	local stats = {}
	for id, stat in pairs(self:GetEntity().statsScript:GetStats()) do
		table.insert(stats, stat:ToTable())
	end
	
	return {
		id = self.properties.id,
		templateName = self:GetEntity():GetTemplate():GetName(),
		hp = self.properties.hp,
		moves = moves,
		index = self.properties.index,
		stats = stats
	}	
end

function MonsterScript:ForWidget()
	local moves = {}
	
	self:UpdateMoves()
	for id, move in pairs(self:GetMoves()) do 
		if move.properties.equipped then 
			table.insert(moves, move:ForWidget())
		end
	end
	
	table.sort(moves, function(a,b)
		return a.index < b.index
	end)
	
	local stats = {}
	for id, stat in pairs(self:GetEntity().statsScript:GetStats()) do
		if id ~= "level" then 
			table.insert(stats, stat:ForWidget())
		end
	end
	
	table.insert(stats, 1, self:GetEntity().statsScript:GetStat("level"):ForWidget())
	
	return {
		id = self.properties.id,
		name = tostring(self.properties.name),
		templateName = self:GetEntity():GetTemplate():GetName(),
		hp = self:GetHp(),
		maxHp = self:GetMaxHp(),
		monsterImage = self.properties.fullSprite,
		icon = self.properties.faceSprite,
		moves = moves,
		level = self:GetLevel(),
		stats = stats,
		index = self.properties.index,
	}
end

return MonsterScript
