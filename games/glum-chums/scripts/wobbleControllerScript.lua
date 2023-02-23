local WobbleControllerScript = {}

-- Script properties are defined here
WobbleControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "delay", type = "number" },
}

--This function is called on the server when this entity is created
function WobbleControllerScript:Init()
	self:Schedule(function()
		Wait(self.properties.delay)
		while true do 
			self:GetEntity():PlayTimeline(
				0, self:GetEntity():GetRotation(), "EaseInOut",
				3, Rotation.New(0, 90, 0), "EaseInOut"
			)
			Wait(5 + 3)
			self:GetEntity():PlayTimeline(
				0, self:GetEntity():GetRotation(), "EaseInOut",
				3, Rotation.New(0, 90, 180), "EaseInOut"
			)
			Wait(15 + 3)
		end
		
	end)
end

return WobbleControllerScript
