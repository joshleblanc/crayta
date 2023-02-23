local FollowPathTestScript = {}

-- Script properties are defined here
FollowPathTestScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function FollowPathTestScript:Init()
end

function FollowPathTestScript:HandleReachCheckpoint(user, index, overrides)
	print("Handling reach checkpoint", IsInSchedule())
	if index == 2 then
		Wait(2)
	end
	
	if index == 4 then 
		print("Overriding index")
		overrides.nextIndex = 1
	end
end

function FollowPathTestScript:HandleLeaveCheckpoint(user, index)
	print("Leave")
end

return FollowPathTestScript
