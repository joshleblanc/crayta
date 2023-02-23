local UserTimeFixScript = {}

-- Script properties are defined here
UserTimeFixScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function UserTimeFixScript:FixTime(newTime)
	GetWorld().startTime = newTime
end

return UserTimeFixScript
