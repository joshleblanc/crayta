local PushPayloadActivityScript = {}

-- Script properties are defined here
PushPayloadActivityScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "trigger", type = "entity" }
}

--This function is called on the server when this entity is created
function PushPayloadActivityScript:Init()
	self.proximityTrigger = self.properties.trigger:FindScript("rangeIndicatorScript") 
	
	self:Schedule(function()
		while true do
			local team = self.proximityTrigger.properties.owner
			if team > 0 then 
				local players = self.proximityTrigger.counts[team]
				for _, player in ipairs(players) do 
					if player:IsValid() and player:IsAlive() then 
						player:GetUser():SendXPEvent("push-payload")
					end
				end
			end
			
			Wait(5)
		end
	end)
end

return PushPayloadActivityScript
