local TerrainScript = {}

-- Script properties are defined here
TerrainScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function TerrainScript:Init()
end

function TerrainScript:Spin(timeToReset)
	return self:GetEntity():PlayTimeline(
		0, self:GetEntity():GetRotation(),
		timeToReset, Rotation.New(0, 1080, 0)
	)
end

return TerrainScript
