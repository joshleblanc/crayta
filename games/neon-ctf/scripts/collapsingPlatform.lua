local CollapsingPlatform = {}

-- Script properties are defined here
CollapsingPlatform.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "finalRotation", type = "rotation" }
}

--This function is called on the server when this entity is created
function CollapsingPlatform:Init()
	self.originalPosition = self:GetEntity():GetPosition()
	self.originalRotation = self:GetEntity():GetRotation()
end

function CollapsingPlatform:PerformRotation(rotation)
	self:Schedule(function()
		local time = 0
		while true do
			local dt = Wait()
			time = time + dt
			local newRotation = Rotation.Lerp(self:GetEntity():GetRotation(), rotation, time)
			self:GetEntity():SetRelativeRotation(newRotation)
			if time >= 1 then
				break
			end
		end
	
	end)
end

function CollapsingPlatform:Open()
	self:PerformRotation(self.properties.finalRotation)
end

function CollapsingPlatform:Close()
	self:PerformRotation(self.originalRotation)
end

return CollapsingPlatform
