local DoorSoundLazyScript = {}

-- Script properties are defined here
DoorSoundLazyScript.Properties = {
	-- Example property
	{name = "openSound", type = "entity"},
}

--This function is called on the server when this entity is created
function DoorSoundLazyScript:Init()
end

function DoorSoundLazyScript:Play()
	self.properties.openSound.active = true
end


function DoorSoundLazyScript:Stop()
	self.properties.openSound.active = false
end

return DoorSoundLazyScript
