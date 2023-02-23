local LightBlockerScript = {}

-- Script properties are defined here
LightBlockerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function LightBlockerScript:Init()
	self:Rotate()
end

function LightBlockerScript:ClientInit()
	self:Rotate()
end

function LightBlockerScript:Rotate()
	self:Schedule(function()
		while(true) do
			self:GetEntity():AlterRotation(Rotation.New(0, 359, 0), 1)
			Wait(1)
		end
	end)
end

return LightBlockerScript
