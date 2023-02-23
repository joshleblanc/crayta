local HandRailsScript = {}

-- Script properties are defined here
HandRailsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function HandRailsScript:Init()
	self.handRails = self:GetEntity():GetChildren()
	self:Open()
end

function HandRailsScript:Open()
	for _, handrail in ipairs(self.handRails) do
		handrail:PlayRelativeTimeline(
			0, handrail:GetRelativePosition(),
			3, handrail:GetRelativePosition() - Vector.New(0, 0, 350)
		)
	end
end

function HandRailsScript:Close()
	for _, handrail in ipairs(self.handRails) do
		handrail:PlayRelativeTimeline(
			0, handrail:GetRelativePosition(),
			3, handrail:GetRelativePosition() + Vector.New(0, 0, 350)
		)
	end
end

return HandRailsScript
