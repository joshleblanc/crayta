local NoEffectScript = {}

-- Script properties are defined here
NoEffectScript.Properties = {
	-- Example property
	{ name = "moveId", type = "string" },
}

--This function is called on the server when this entity is created
function NoEffectScript:Init()
end

function NoEffectScript:Apply(battle)
	if battle.state.move.properties.id ~= self.properties.moveId then return end 
	
	table.insert(battle.state.messages, "Nothing happened!")
end

return NoEffectScript
