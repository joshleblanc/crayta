local MirrorMoveScript = {}

-- Script properties are defined here
MirrorMoveScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}


function MirrorMoveScript:Apply(battle)
	if battle.state.move.properties.id ~= "mimic" then return end 
	
	battle.endMoveEarly = true
	
	local move = battle.state.to.lastMove
	
	battle:UseMove(battle.state.from, move, battle.state.to, battle.state.ai, battle.state.messages)
end

return MirrorMoveScript
