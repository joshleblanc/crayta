local PickUpThingsScript = {}

-- Script properties are defined here
PickUpThingsScript.Properties = {
	-- Example property
	{ name = "name", type = "string" }
}

function PickUpThingsScript:SendPickupChallenge(user)
	user:SendChallengeEvent("pick-up-things", { thing = self.properties.name })
end

return PickUpThingsScript
