local ClassRoomOpenScript = {}

-- Script properties are defined here
ClassRoomOpenScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ClassRoomOpenScript:Init()
	
end

function ClassRoomOpenScript:OpenClassDoor()
self:Schedule(function()
		local params = { looping = false, playbackTime = 3, positionTime = 0.5}
		self:GetEntity():PlayAnimation("opening",params)
		Wait(5)
		params.playbackTime = .5
		self:GetEntity():PlayAnimation("closing",params)
	end)
end

return ClassRoomOpenScript
