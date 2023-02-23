local WorldCompassScript = {}

-- Script properties are defined here
WorldCompassScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function WorldCompassScript:Init()
	self.targets = GetWorld():FindAllScripts("compassTargetScript")
end

function WorldCompassScript:OnUserLogin(user)
	user.userCompassScript:SetTargets(self.targets)
end

return WorldCompassScript
