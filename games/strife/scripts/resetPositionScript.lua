local ResetPositionScript = {}

-- Script properties are defined here
ResetPositionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "twsystem", type = "entity" },
	{ name = "track", type = "entity" }
}

--This function is called on the server when this entity is created
function ResetPositionScript:Init()
	self.initialPosition = self:GetEntity():GetPosition()
	self.initialRotation = self:GetEntity():GetRotation()
end

function ResetPositionScript:Reset()
	print("Resetting", self.initialPosition, self:GetEntity():GetPosition())
	self:GetEntity():SetPosition(self.initialPosition)
	self:GetEntity():SetRotation(self.initialRotation)
	--self.properties.twsystem:SendToScripts("SnapToTrack", self:GetEntity().TWVehicle)
	self:GetEntity().TWTransform:SetState({ track = self.properties.track.TWTrackSection, t = 1, tDirection = -1 })
end

return ResetPositionScript
