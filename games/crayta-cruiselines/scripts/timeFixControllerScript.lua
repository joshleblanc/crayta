local TimeFixControllerScript = {}

-- Script properties are defined here
TimeFixControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function TimeFixControllerScript:Init()
	self.world = GetWorld()
	self:Schedule(function()
		while true do
			self.world:ForEachUser(function(user)
				user:SendToLocal("FixTime", self.world:GetTimeOfDay())
			end)
			Wait(10)
		end
	end)
end


return TimeFixControllerScript
