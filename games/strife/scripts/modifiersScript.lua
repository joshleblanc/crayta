local ModifiersScript = {}

-- Script properties are defined here
ModifiersScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

local FALL_DAMAGE_MULTIPLIER = 0.5
local WEAPON_DAMAGE_MULTIPLIER = 0.5
local HEALTH_AMT = 250

function ModifiersScript:Init()
	self.buffs = {}
	self.curses = {}
	self.fallDamageOverrides = self:GetEntity().fallDamageOverridesScript
	self.healthOverride = self:GetEntity().healthOverride
end

function ModifiersScript:LocalInit()
	self.widget = self:GetEntity().modifiersWidget
	self.widget.js.data.modifiers = {}
	self.buffs = {}
	self.curses = {}
end

function ModifiersScript:ApplyBuff(buffId, desc)
	table.insert(self.buffs, { id = buffId, description = desc, buff = true })
	
	if buffId == "fall-damage" then 
		self.fallDamageOverrides.properties.damageMultiplier = self.fallDamageOverrides.properties.damageMultiplier - FALL_DAMAGE_MULTIPLIER
	elseif buffId == "health" then
		self.healthOverride.properties.maxHp = self.healthOverride.properties.maxHp + HEALTH_AMT
	end 
end

function ModifiersScript:ApplyCurse(curseId, desc)
	table.insert(self.curses, { id = curseId, description = desc, buff = false })
	
	if curseId == "fall-damage" then 
		self.fallDamageOverrides.properties.damageMultiplier = self.fallDamageOverrides.properties.damageMultiplier + FALL_DAMAGE_MULTIPLIER
	elseif curseId == "health" then 
		self.healthOverride.properties.maxHp = math.max(1, self.healthOverride.properties.maxHp - HEALTH_AMT)
	end
end

function ModifiersScript:UpdateModifiersWidget()
	self:SendToLocal("LocalUpdateModifiers", self.buffs, self.curses)
end

function ModifiersScript:LocalUpdateModifiers(buffs, curses) 
	self.buffs = buffs 
	self.curses = curses
	
	local buffCounts = {}
	local curseCounts = {}
	
	for _, b in ipairs(buffs) do 
		buffCounts[b.id] = buffCounts[b.id] or { count = 0, description = b.description, buff = true }
		buffCounts[b.id].count = buffCounts[b.id].count + 1
	end
	
	for _, c in ipairs(curses) do 
		curseCounts[c.id] = curseCounts[c.id] or { count = 0, description = c.description, buff = false }
		curseCounts[c.id].count = curseCounts[c.id].count + 1
	end
	
	local data = { }
	for _, b in pairs(buffCounts) do 
		table.insert(data, b)
	end
	
	for _, c in pairs(curseCounts) do 
		table.insert(data, c)
	end
	
	self.widget.js.data.modifiers = data
end

function ModifiersScript:ModifyDamage(dmg)

	local damageModifier = WEAPON_DAMAGE_MULTIPLIER
	
	for _, buff in ipairs(self.buffs) do 
		if buff.id == "weapon-damage" then 
			dmg = dmg + (dmg * damageModifier)
		end
	end
	
	for _, curse in ipairs(self.curses) do 
		if curse.id == "weapon-damage" then 
			dmg = dmg - (dmg * damageModifier)
		end
	end
	
	return dmg
end

function ModifiersScript:Reset()	
	self:Init()
	self:SendToLocal("LocalInit")
end

function ModifiersScript:LocalOnTick()

end

return ModifiersScript
