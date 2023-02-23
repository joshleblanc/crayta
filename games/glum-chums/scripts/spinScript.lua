local SpinScript = {}

-- Script properties are defined here
SpinScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function SpinScript:Init()
	self:Schedule(function()
		while true do 
			Wait(self:GetEntity():AlterRotation(Rotation.New(0, 360, 0), 5))
			self:GetEntity():SetRotation(Rotation.Zero)
		end
	end)
end

return SpinScript
