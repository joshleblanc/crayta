local SpectateCameraScript = {}

-- Script properties are defined here
SpectateCameraScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function SpectateCameraScript:Init()
	self.origPos = self:GetEntity():GetPosition()
end

function SpectateCameraScript:Zoom()
	self:GetEntity():AlterPosition(self:GetEntity():GetPosition() - Vector.New(0, 0, 200), 5)
end

function SpectateCameraScript:Reset()
	self:GetEntity():SetPosition(self.origPos)
end

return SpectateCameraScript
