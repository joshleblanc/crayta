local WorldSettingsResetScript = {}

-- Script properties are defined here
WorldSettingsResetScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function WorldSettingsResetScript:LocalInit()
	self.defaultPostProcess = GetWorld().postProcess
	self.defaultStartTime = GetWorld().startTime
	self.defaultColorGrading = GetWorld().colorGrading
	self.defaultFogStartDistance = GetWorld().fogStartDistance
	self.defaultFogDensity = GetWorld().fogDensity
	self.defaultFogFallout = GetWorld().fogFalloff
end


function WorldSettingsResetScript:ResetWorldSettings()
	self:GetEntity():SendToLocal("ResetLocally")
end

function WorldSettingsResetScript:ResetLocally()
	GetWorld().postProcess = self.defaultPostProcess
	GetWorld().startTime = self.defaultStartTime
	GetWorld().colorGrading = self.defaultColorGrading
	GetWorld().fogStartDistance = self.defaultFogStartDistance
	GetWorld().fogDensity = self.defaultFogDensity
	GetWorld().fogFalloff = self.defaultFogFallout
end

return WorldSettingsResetScript
