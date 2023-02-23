local AdjustStatStageScript = {}

-- Script properties are defined here
AdjustStatStageScript.Properties = {
	-- Example property
	{ name = "moveId", type = "string" },
	{ name = "stat", type = "string", options = { "atk", "def", "speed", "spatk", "spdef", "acc", "eva" }, default = "atk" },
	{ name = "stageAdjustment", type = "number", default = 0 },
	{ name = "target", type = "string", options = { "source", "target" }, default = "source" },
	{ name = "chance", type = "number", default = 1 },
}

local MESSAGES = {
	[-6] = "{1}'s {2} dropped drastically!",
	[-5] = "{1}'s {2} dropped drastically!",
	[-4] = "{1}'s {2} dropped drastically!",
	[-3] = "{1}'s {2} dropped drastically!",
	[-2] = "{1}'s {2} dropped significantly!",
	[-1] = "{1}'s {2} dropped!",
	[0] = "Nothing happened!",
	[1] = "{1}'s {2} rose!",
	[2] = "{1}'s {2} rose significantly!",
	[3] = "{1}'s {3} rose dramatically!",
	[4] = "{1}'s {3} rose dramatically!",
	[5] = "{1}'s {3} rose dramatically!",
	[6] = "{1}'s {3} rose dramatically!",
}

function AdjustStatStageScript:Apply(battle)
	if battle.state.move.properties.id ~= self.properties.moveId then return end 
	
	local target 
	if self.properties.target == "source" then 
		target = battle.state.from
	else
		target = battle.state.to
	end

	if math.random() < self.properties.chance then 
		local change = target:AdjustStatStage(self.properties.stat, self.properties.stageAdjustment)
		
		print("Running change", change)
		local message = MESSAGES[change]
	
		table.insert(battle.state.messages, FormatString(message, target.properties.name, self.properties.stat))
	end
	
end

return AdjustStatStageScript
