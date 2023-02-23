local TriggerTrackerScript = {}

-- Script properties are defined here
TriggerTrackerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function TriggerTrackerScript:Init()
	self.contents = {}
end

function TriggerTrackerScript:OnTriggerEnter(e)
	self.contents[e] = true
end

function TriggerTrackerScript:OnTriggerExit(e)
	self.contents[e] = nil
end

function TriggerTrackerScript:Contents()
	local t = {}
	
	for k, v in pairs(self.contents) do 
		if Entity.IsValid(k) then 
			table.insert(t, k)
		else 
			self.contents[k] = nil
		end
	end
	
	return t
end

return TriggerTrackerScript
