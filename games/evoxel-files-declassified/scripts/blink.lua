local Blink = {}

-- Script properties are defined here
Blink.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function Blink:Init()
	self:Schedule(function() 
		while(true) do
			self:GetEntity():SetRotation(self:GetEntity():GetRotation() + Rotation.New(0, 0, 90))
			Wait(0.1)
			self:GetEntity():SetRotation(self:GetEntity():GetRotation() - Rotation.New(0, 0, 90))
			Wait(5)
		end
	end)
end

return Blink
