local ApplyStatusEffectsScript = {}

-- Script properties are defined here
ApplyStatusEffectsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "moveId", type = "string" },
	{ name = "target", type = "string", options = { "source", "target" }, default = "source" },
	{ name = "chance", type = "number", default = 1 },
	{ name = "statusEffect", type = "string", options = { "poisoned", "confused", "flinching", "freezing", "burning" }, default = "poisoned" },
}

--This function is called on the server when this entity is created
function ApplyStatusEffectsScript:Init()
end

function ApplyStatusEffectsScript:Apply(battle)
	if battle.state.move.properties.id ~= self.properties.moveId then return end 
	
	local target 
	if self.properties.target == "source" then 
		target = battle.state.from
	else
		target = battle.state.to
	end
	
	target:ApplyStatusEffect(self.properties.statusEffect)
	
	table.insert(battle.state.messages, FormatString("{1} has been {2}!", target.properties.name, self.properties.statusEffect))
end

return ApplyStatusEffectsScript
