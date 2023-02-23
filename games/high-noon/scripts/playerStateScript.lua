local PlayerStateScript = {}

-- Script properties are defined here
PlayerStateScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "playing", type = "boolean", default = false }
}

function PlayerStateScript:Play()
	self.properties.playing = true
	self:GetEntity().spawnUserScript.properties.spawnPoint = nil
	self:GetEntity().spawnUserScript:SendToScript("SpawnInternal", false)
end

function PlayerStateScript:Lobby()
	self.properties.playing = false
end

return PlayerStateScript
