local FloorScript = {}

-- Script properties are defined here
FloorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function FloorScript:Init()
	self.initialPosition = self:GetEntity():GetPosition()
	self.topPosition = Vector.New(0, 0, 3975)
end

function FloorScript:Rise()
	self:GetEntity():PlayTimeline(
		0, self.initialPosition,
		0.25, self.topPosition
	)
end


function FloorScript:Reset()
	self:GetEntity():PlayTimeline(
		0, self.topPosition,
		1, self.initialPosition
	)
end

return FloorScript
