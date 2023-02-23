local CellBarsScript = {}

-- Script properties are defined here
CellBarsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function CellBarsScript:Init()
	self.bars = self:GetEntity():GetChildren()
	self:Open()
end

function CellBarsScript:Open()
	for _, bar in ipairs(self.bars) do
		bar:PlayRelativeTimeline(
			0, bar:GetRelativePosition(),
			3, bar:GetRelativePosition() + Vector.New(0, 0, 350)
		)
	end
end

function CellBarsScript:Close()
	for _, bar in ipairs(self.bars) do
		bar:PlayRelativeTimeline(
			0, bar:GetRelativePosition(),
			3, bar:GetRelativePosition() - Vector.New(0, 0, 350)
		)
	end
end

return CellBarsScript
