local MonsterControllerScript = {}

-- Script properties are defined here
MonsterControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function MonsterControllerScript:Init()
	local monsters = self:GetEntity():FindAllScripts("monsterScript", true)

	self.monsters = {}
	for _, monster in ipairs(monsters) do 
		self.monsters[monster.properties.id] = monster
	end
end

function MonsterControllerScript:ClientInit()
	self:Init()
end

function MonsterControllerScript:FindMonsterByTemplate(template)
	return self:FindMonsterById(template:FindScriptProperty("id"))
end

function MonsterControllerScript:FindMonsterById(id)
	return self.monsters[id]
end

return MonsterControllerScript
