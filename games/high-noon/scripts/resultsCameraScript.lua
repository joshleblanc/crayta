local ResultsCameraScript = {}

-- Script properties are defined here
ResultsCameraScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ResultsCameraScript:Init()
	self.initialPosition = self:GetEntity():GetPosition()
end

function ResultsCameraScript:Reset()

	GetWorld().startTime = 0
	GetWorld().heightFogDensity = 1
	
	self:GetEntity():AlterPosition(self.initialPosition, self.initialPosition + Vector.New(0, 4315.961, 0), 60)
end

return ResultsCameraScript
