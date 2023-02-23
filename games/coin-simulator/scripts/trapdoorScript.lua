local TrapdoorScript = {}

-- Script properties are defined here
TrapdoorScript.Properties = {
	-- Example property
	{ name = "direction", type = "string", options = { "left", "right" }, default = "left" }
} 

--This function is called on the server when this entity is created
function TrapdoorScript:Init()
	self.openPosition = self:GetEntity():GetPosition()
	self.openRotation = self:GetEntity():GetRotation()
	
	if self.properties.direction == "right" then
		self.closedPosition = self:GetEntity():GetPosition() + Vector.New(0, -50, -75)
		self.closedRotation = self:GetEntity():GetRotation() + Rotation.New(0, 0, -90)
	else
		self.closedPosition = self:GetEntity():GetPosition() + Vector.New(0, 75, -50)
		self.closedRotation = self:GetEntity():GetRotation() + Rotation.New(0, 0, 90)
	end
end

function TrapdoorScript:Close()
	self:GetEntity():PlayTimeline(
		0, self.openPosition, self.openRotation,
		0.1, self.closedPosition, self.closedRotation
	)
end

function TrapdoorScript:Open()
	self:GetEntity():PlayTimeline(
		0, self.closedPosition, self.closedRotation,
		2, self.openPosition, self.openRotation
	)
end

return TrapdoorScript