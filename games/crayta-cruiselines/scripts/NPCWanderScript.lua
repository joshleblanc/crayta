local NPCWanderScript = {}

-- Script properties are defined here
NPCWanderScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function NPCWanderScript:Init()
	self:Wander()
end



return NPCWanderScript
