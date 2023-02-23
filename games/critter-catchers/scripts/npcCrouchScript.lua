local NpcCrouchScript = {}

-- Script properties are defined here
NpcCrouchScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function NpcCrouchScript:Init()
self:Schedule(function()
		Wait(10)
			print("waiting to settle..")
		self:GetEntity():SetCrouching(true)
	end)
end

return NpcCrouchScript
