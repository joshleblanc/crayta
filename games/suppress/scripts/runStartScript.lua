local RunStartScript = {}

-- Script properties are defined here
RunStartScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function RunStartScript:Init()
end

function RunStartScript:TrySetOwner(user)
	print("Trying to set owner")
	user:SendToScripts("StartRun")
end

return RunStartScript
