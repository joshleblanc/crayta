local LocationPollutionScript = {}

-- Script properties are defined here
LocationPollutionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "maxPollution", type = "number", default = 100 }
}

--This function is called on the server when this entity is created
function LocationPollutionScript:Init()
end

function LocationPollutionScript:GetId()
	return FormatString("pollution-{1}", self:GetEntity().locationScript.properties.id)
end

function LocationPollutionScript:GetPollution(cb)
	GameStorage.GetCounter(self:GetId(), cb)
end

function LocationPollutionScript:AddPollution(amt)
	if amt == 0 then return end 
	
	self:GetPollution(function(pol)
		if amt < 0 then 
			if pol > 0 then 
				GameStorage.UpdateCounter(self:GetId(), math.max(amt, -pol))
			end 
		else 
			if pol < self.properties.maxPollution then 
				local diff = self.properties.maxPollution - pol
				GameStorage.UpdateCounter(self:GetId(), max.min(amt, diff)) 
			end
		end
		
	end)
	
	GameStorage.UpdateCounter(self:GetId(), amt)
end

return LocationPollutionScript
