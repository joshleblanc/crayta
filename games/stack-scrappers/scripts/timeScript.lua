local TimeScript = {}

-- Script properties are defined here
TimeScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function TimeScript:ClientInit()
	self.time = 0
end



function TimeScript:ClientOnTick()
	
	
	GetWorld().startTime = self.time
	self.time = self.time  + 0.01
	Print(GetWorld():GetTimeOfDay())
end


return TimeScript