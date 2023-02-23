local EnemyScript = {}

-- Script properties are defined here
EnemyScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "xpReward", type = "number", default = 25 },
	{ name = "xpTemplate", type = "template" }
}

--This function is called on the server when this entity is created
function EnemyScript:Init()
end

function EnemyScript:HandleDeath(killer)
	local depth = killer:GetUser().userRunScript.currentNode.depth
	print("Adding XP at depth", depth)
	killer:GetUser():SendToScripts("AddToInventory", self.properties.xpTemplate, math.floor(self.properties.xpReward * depth))
end

return EnemyScript
