local StatScript = {}

-- Script properties are defined here
StatScript.Properties = {
	{ name = "name", type = "text" },
	{ name = "id", type = "string" },
	{ name = "xp", type = "number", default = 0, editable = false },
	{ name = "maxLevel", type = "number" },
	{ name = "icon", type = "string" },
	{ name = "randomizeIv", type = "boolean", default = true },
	{ name = "iv", type = "number", max=15, min=0, default = 0, visibleIf=function(p) return not p.randomizeIv end },
	{ name = "ev", type = "number", editable = false, default = 0 },
	{ name = "linkTo", type = "string", group="link" },
	{ name = "baseLevel", type = "number", default = 1, group="link" },
	{ name = "bonus", type = "number", default = 0, group="link"},
	{ name = "addLevel", type = "boolean", default = false, group="link" },
}

function StatScript:Init()
	if self.properties.linkTo then 
		self:GetEntity().statsScript.properties.onStatLevelUp:Listen(self, "HandleStatChange")
	end
	
	self:SeedIv()
	
	self:GetEntity().statsScript:SetLevel(self.properties.id, self.properties.baseLevel)
end

function StatScript:SeedIv()
	if self.properties.randomizeIv then 
		self.properties.iv = math.random(0, 15)
	end
end

function StatScript:HandleStatChange(entity, id, xp, stat)
	if id == self.properties.linkTo then 
		self:ComputeXpForLinkedStat()
	end
end

function StatScript:ComputeXpForLinkedStat()
	if #self.properties.linkTo == 0 then return end 
	
	local linkedStat = self:GetEntity().statsScript:GetStat(self.properties.linkTo)
	
	assert(linkedStat, FormatString("{1}: Tried to compute linked stat: {2}, but no stat exists", self.properties.id, self.properties.linkTo))
	
	-- floor((2 * B) * L / 100 + 5)
	local level = linkedStat:Level()
	
	local a = self.properties.baseLevel + self.properties.iv
	local b = 2 * a
	local c = b + math.floor(math.sqrt(self.properties.ev) / 4)
	
	local addtl = math.floor(((c * level) / 100) + self.properties.bonus)
	if self.properties.addLevel then 
		addtl = addtl + level
	end
	
	local newLevel = addtl
	
	--local originalXp = self:XpForLevel(self.properties.baseLevel)
	--local incAmt = originalXp * (1 / 50)
	
	self.properties.xp = self:XpForLevel(newLevel) --originalXp + (incAmt * level)
end

function StatScript:Name()
	return self.properties.name
end

function StatScript:XpForLevel(level)
	return math.pow(level, 3)
	--return (((level + 1) * level) / 2) * 100
end


function StatScript:LevelFromXp(xp)
	return math.ceil(xp ^ (1/3))
	--return math.floor((-1 + math.sqrt(1 + (8 * ( xp / 100 )))) / 2)
end

function StatScript:Level()
	return self:LevelFromXp(self.properties.xp)
end

function StatScript:CurrentXp()
	return self.properties.xp
end

function StatScript:PercentToNextLevel()
	return self:CurrentXp() / self:RequiredXp()
end

function StatScript:RequiredXp()
	return self:XpForLevel(self:Level())
end

function StatScript:XpRemaining()
	return self:RequiredXp() - self:CurrentXp()
end

function StatScript:AddXp(xp)
	if self:Level() <= self.properties.maxLevel then
		self.properties.xp = self.properties.xp + xp
		return true
	else
		return false
	end
end

function StatScript:AddEv(xp)
	self.properties.ev = math.min(65535, self.properties.ev + xp)
end

function StatScript:Load(doc)
	self.properties.xp = doc.xp
	self.properties.iv = doc.iv
	self.properties.ev = doc.ev
end

function StatScript:ForWidget()
	return {
		name = self.properties.name,
		id = self.properties.id,
		xp = self.properties.xp,
		level = self:Level(),
		iv = self.properties.iv,
		requiredXp = self:RequiredXp()
	}
end

function StatScript:ToTable()
	return {
		id = self.properties.id,
		xp = self.properties.xp,
		iv = self.properties.iv,
		ev = self.properties.ev
	}
end


return StatScript
