local HitThingsChallengeScript = {}

-- Script properties are defined here
HitThingsChallengeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "string" }
}

--This function is called on the server when this entity is created
function HitThingsChallengeScript:Init()
end

function HitThingsChallengeScript:EntityHit(hit, user)
	user:SendChallengeEvent("hit-things", { target = self.properties.name })
end

return HitThingsChallengeScript
