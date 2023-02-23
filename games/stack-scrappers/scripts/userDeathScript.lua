local UserDeathScript = {}

-- Script properties are defined here
UserDeathScript.Properties = {
	-- Example property
	{name = "timeToWait", type = "number", default = 6},
}

--This function is called on the server when this entity is created
function UserDeathScript:Init()
end

function UserDeathScript:HandleDeath()
	self:Schedule(
		function()
			-- self:GetEntity():SendToScripts("ApplyToUser")
				
			--self:GetEntity():SendToScripts("DoScreenFadeOut", .2)
			Wait(self.properties.timeToWait)
			self:GetEntity():SendToScripts("SpawnInternal",false)
		end)
		
end

return UserDeathScript
