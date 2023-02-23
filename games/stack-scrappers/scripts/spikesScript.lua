local SpikesScript = {}

-- Script properties are defined here
SpikesScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function SpikesScript:Init()
	local trapScript = self:GetEntity():GetParent().trapScript
	trapScript.properties.onActivate:Listen(self, "Activate")
	trapScript.properties.onDeactivate:Listen(self, "Deactivate")
	self.duration = trapScript.properties.duration
end

function SpikesScript:Activate()
	self:GetEntity():PlayRelativeTimeline({
		0, self:GetEntity():GetRelativePosition(),
		0.1, Vector.New(0, 12.5, 25), "EaseIn"
	})

end

function SpikesScript:Deactivate()
	self:GetEntity():PlayRelativeTimeline({
		0, self:GetEntity():GetRelativePosition(),
		0.25, Vector.New(0, 12.5, -75), "EaseIn"
	})
end

return SpikesScript
