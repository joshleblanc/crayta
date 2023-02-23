local WhirlwindScript = {}

-- Script properties are defined here
WhirlwindScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function WhirlwindScript:Init()
end

function WhirlwindScript:Apply(battle)
	if battle.state.move.properties.id ~= "whirlwind" then return end 
	
	battle.endMoveEarly = true
	
	battle:DisplayFullMessage(messages, function()
		battle:BattleScreenEscape()
		return false
	end)
end

return WhirlwindScript