local LocalLocationSoundScript = {}

-- Script properties are defined here
LocalLocationSoundScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function LocalLocationSoundScript:Init()
end

function LocalLocationSoundScript:HandleLocationSpawn(user)
	user:SendToScripts("DoOnLocal", self:GetEntity(), "PlaySound")
end

function LocalLocationSoundScript:HandlePlayerEnter(user)
	user:SendToScripts("DoOnLocal", self:GetEntity(), "PlaySound")
end

function LocalLocationSoundScript:HandlePlayerExit(user)
	user:SendToScripts("DoOnLocal", self:GetEntity(), "StopSound")
end

function LocalLocationSoundScript:PlaySound()
	self:GetEntity().active = true
end

function LocalLocationSoundScript:StopSound()
	self:GetEntity().active = false
end

return LocalLocationSoundScript
