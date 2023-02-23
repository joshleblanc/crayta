local TeamDriverScript = {}

-- Script properties are defined here
TeamDriverScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "maxSpeed", type = "number", default = 100 }
}

function TeamDriverScript:HandleOwnerChange(owner, num1, num2)
	if owner == 2 and num1 == 0 then 
		self:GetEntity().TWVehicle.properties.gear = 1
		self:GetEntity().TWVehicleModuleAutoDriver.properties.targetSpeed = self:CalcSpeed(num2)
	elseif owner == 1 and num2 == 0 then 
		self:GetEntity().TWVehicle.properties.gear = -1
		self:GetEntity().TWVehicleModuleAutoDriver.properties.targetSpeed = self:CalcSpeed(num1)
	else 
		self:GetEntity().TWVehicleModuleAutoDriver.properties.targetSpeed = 0
	end
end

function TeamDriverScript:CalcSpeed(numPlayers) 
	return self.properties.maxSpeed + (self.properties.maxSpeed * math.log(numPlayers))
end

return TeamDriverScript
