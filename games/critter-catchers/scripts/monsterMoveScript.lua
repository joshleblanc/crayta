local MonsterMoveScript = {}

local TYPES = { "normal", "fighting", "flying", "poison", "ground", "rock", "bug", "ghost", "steel", "fire", "water", "grass", "electric", "psychic", "ice", "dragon", "dark", "fairy" }

-- Script properties are defined here
MonsterMoveScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" },
	{ name = "name", type = "text" },
	{ name = "description", type = "text" },
	{ name = "type", type = "string", options = TYPES, default = "normal" },
	{ name = "category", type = "string", options = { "physical", "special", "status" }, default = "physical" },
	{ name = "power", type = "number", default = 100 },
	{ name = "accuracy", type = "number", default = 100 },
	{ name = "numAttacks", type = "number", default = 1 },
	{ name = "minLevel", type = "number", default = 0 },
	{ name = "equipped", type = "boolean", default = true },
	{ name = "pp", type = "number", default = 35 },
	{ name = "remainingMoves", type = "number", default = 35 },
	{ name = "skipped", type = "boolean", default = false },
	{ name = "index", type = "number", default = 1 },
}

local EFFECTIVENESS = {
	normal = {
		normal = 1,
		fighting = 1,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 0.5,
		bug = 1,
		ghost = 0,
		steel = 0.5,
		fire = 1,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 1,
		ice = 1,
		dragon = 1,
		dark = 1,
		fairy = 1
	},
	flying = {
		normal = 1,
		fighting = 2,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 0.5,
		bug = 2,
		ghost = 1,
		steel = 0.5,
		fire = 1,
		water = 1,
		grass = 2,
		electric = 0.5,
		psychic = 1,
		ice = 1,
		dragon = 1,
		dark = 1,
		fairy = 1,
	},
	fighting = {
		normal = 2,
		fighting = 1,
		flying = 0.5,
		poison = 0.5,
		ground = 1,
		rock = 2,
		bug = 0.5,
		ghost = 0,
		steel = 2,
		fire = 1,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 0.5,
		ice = 2,
		dragon = 1,
		dark = 2,
		fairy = 0.5
	},
	poison = {
		normal = 1,
		fighting = 1,
		flying = 1,
		poison = 0.5,
		ground = 0.5,
		rock = 0.5,
		bug = 1,
		ghost = 0.5,
		steel = 0,
		fire = 1,
		water = 1,
		grass = 2,
		electric = 1,
		psychic = 1,
		ice = 1,
		dragon = 1,
		dark = 1,
		fairy = 2
	},
	ground = {
		normal = 1,
		fighting  = 1,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 0.5,
		bug = 1,
		ghost = 0,
		steel = 0.5,
		fire = 1,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 1,
		ice = 1,
		dragon = 1,
		dark = 1,
		fairy = 1,
	},
	rock = {
		normal = 1,
		fighting = 0.5,
		flying = 2,
		poison = 1,
		ground = 0.5,
		rock = 1,
		bug = 2,
		ghost = 1,
		steel = 0.5,
		fire = 2,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 1,
		ice = 2,
		dragon = 1,
		dark = 1,
		fairy = 1
	},
	bug = {
		normal = 1,
		fighting = 0.5,
		flying = 0.5,
		poison = 0.5,
		ground = 1,
		rock = 1,
		bug = 1,
		ghost = 0.5,
		steel = 0.5,
		fire = 0.5,
		water = 1,
		grass = 2,
		electric = 1,
		psychic = 2,
		ice = 1,
		dragon = 1,
		dark = 2,
		fairy = 0.5
	},
	ghost = {
		normal = 0,
		fighting = 1,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 1,
		bug = 1,
		ghost = 2,
		steel = 1,
		fire = 1,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 2,
		ice = 1,
		dragon = 1,
		dark = 0.5,
		fairy = 1
	}, 
	steel = {
		normal = 1,
		fighting = 1,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 2,
		bug = 1,
		ghost = 1,
		steel = 0.5,
		fire = 0.5,
		water = 0.5,
		grass = 1,
		electric = 0.5,
		psychic = 1,
		ice = 2,
		dragon = 1,
		dark = 1,
		fairy = 2
	},
	fire = {
		normal = 1,
		fighting = 1,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 0.5,
		bug = 2,
		ghost = 1,
		steel = 2,
		fire = 0.5,
		water = 0.5,
		grass = 2,
		electric = 1,
		psychic = 1,
		ice = 2,
		dragon = 0.5,
		dark = 1,
		fairy = 1,
	},
	water = {
		normal = 1,
		fighting = 1,
		flying = 1,
		poison = 1,
		ground = 2,
		rock = 2,
		bug = 1,
		ghost = 1,
		steel = 1,
		fire = 2,
		water = 0.5,
		grass = 0.5,
		electric = 1,
		psychic = 1,
		ice = 1,
		dragon = 0.5,
		dark = 1,
		fairy = 1,
	},
	grass = {
		normal = 1,
		fighting = 1,
		flying = 0.5,
		poison = 0.5,
		ground = 2,
		rock = 2,
		bug = 0.5,
		ghost = 1,
		steel = 0.5,
		fire = 0.5,
		water = 2,
		grass = 0.5,
		electric = 1,
		psychic = 1,
		ice = 1,
		dragon = 0.5,
		dark = 1,
		fairy = 1,
	},
	electric = {
		normal = 1,
		fighting = 1,
		flying = 2,
		poison = 1,
		ground = 0,
		rock = 1,
		bug = 1,
		ghost = 1,
		steel = 1,
		fire = 1,
		water = 2,
		grass = 0.5,
		electric = 0.5,
		psychic = 1,
		ice = 1,
		dragon = 0.5,
		dark = 1,
		fairy = 1,
	},
	psychic = {
		normal = 1,
		fighting = 2,
		flying = 1,
		poison = 2,
		ground = 1,
		rock = 1,
		bug = 1,
		ghost = 1,
		steel = 0.5,
		fire = 1,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 0.5,
		ice = 1,
		dragon = 1,
		dark = 0,
		fairy = 1
	},
	ice = {
		normal = 1,
		fighting = 1,
		flying = 2,
		poison = 1,
		ground = 2,
		rock = 1,
		bug = 1,
		ghost = 1,
		steel = 0.5,
		fire = 0.5,
		water = 0.5,
		grass = 2,
		electric = 1,
		psychic = 1,
		ice = 0.5,
		dragon = 2,
		dark = 1,
		fairy = 1,
	},
	dragon = {
		normal = 1,
		fighting = 1,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 1,
		bug = 1,
		ghost = 1,
		steel = 0.5,
		fire = 1,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 1,
		ice = 1,
		dragon = 2,
		dark = 1,
		fairy = 0
	},
	dark = {
		normal = 1,
		fighting = 0.5,
		flying = 1,
		poison = 1,
		ground = 1,
		rock = 1,
		bug = 1,
		ghost = 2,
		steel = 1,
		fire = 1,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 2,
		ice = 1,
		dragon = 1,
		dark = 0.5,
		fairy = 0.5
	},
	fairy = {
		normal = 1,
		fighting = 2,
		flying = 1,
		poison = 0.5,
		ground = 1,
		rock = 1,
		bug = 1,
		ghost = 1,
		steel = 0.5,
		fire = 0.5,
		water = 1,
		grass = 1,
		electric = 1,
		psychic = 1,
		ice = 1,
		dragon = 2,
		dark = 2,
		fairy = 1
	}
}


assert(#TYPES == 18, "There is a type missing in the type array")
	
for _, t in ipairs(TYPES) do 
	assert(EFFECTIVENESS[t], FormatString("Effectiveness map is is missing type {1}", t))
end

local metaCount = 0
for k, v in pairs(EFFECTIVENESS) do 
	local count = 0
	metaCount = metaCount + 1
	for kk, vv in pairs(EFFECTIVENESS[k]) do 
		count = count + 1
	end
	assert(count == 18, FormatString("{1} does not have 18 types", k))
	
	for _, t in ipairs(TYPES) do 
		assert(EFFECTIVENESS[k][t], FormatString("{1} is missing type {2}", k, t))
	end
end

assert(metaCount == 18, "Effectiveness map does not have 18 types")

--This function is called on the server when this entity is created
function MonsterMoveScript:Init()
	self.properties.remainingMoves = self.properties.pp
end

function MonsterMoveScript:Load(doc)
	self.properties.remainingMoves = doc.remainingMoves
	self.properties.equipped = doc.equipped
	self.properties.skipped = doc.skipped
	self.properties.index = doc.index
end

function MonsterMoveScript:ToTable()
	return {
		id = self.properties.id,
		remainingMoves = self.properties.remainingMoves,
		index = self.properties.index,
		skipped = self.properties.skipped,
		equipped = self.properties.equipped
	}
end

function MonsterMoveScript:ApplyEffect(battle)
	self:GetEntity():SendToScripts("Apply", battle)
end

function MonsterMoveScript:DamageMultiplier(mon)
	local multiplier = 1
	
	for i=1,#mon.properties.types do 
		multiplier = multiplier * EFFECTIVENESS[self.properties.type][mon.properties.types[i]]
	end
	
	return multiplier
end

function MonsterMoveScript:ResetPp() 
	self.properties.remainingMoves = self.properties.pp
end

function MonsterMoveScript:ForWidget()
	local pwr = self.properties.power
	local acc = self.properties.accuracy
	
	if pwr > 999 then 
		pwr = 999
	end
	
	if pwr <= 0 then 
		pwr = "-"
	end
	
	if acc <= 0 then 
		acc = "-"
	end
	
	return {
		id = self.properties.id,
		name = tostring(self.properties.name),
		power = pwr,
		accuracy = acc,
		description = self.properties.description,
		remainingMoves = self.properties.remainingMoves,
		pp = self.properties.pp,
		minLevel = self.properties.minLevel,
		index = self.properties.index
	}
end

return MonsterMoveScript
