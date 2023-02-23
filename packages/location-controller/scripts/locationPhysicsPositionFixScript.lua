local LocationPhysicsPositionFixScript = {}

-- Script properties are defined here
LocationPhysicsPositionFixScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "root", type = "entity" }
}

--This function is called on the server when this entity is created
function LocationPhysicsPositionFixScript:Init()
	self.originalPosition = self:GetEntity():GetPosition()
	self.originalRotation = self:GetEntity():GetRotation()
	
	if self.properties.root then 
		self.properties.root.locationScript.properties.onLocationSpawn:Listen(self, "HandleLocationSpawn")
	else
		self:HandleLocationSpawn()
	end 
	
end

function LocationPhysicsPositionFixScript:HandleLocationSpawn()
	self:Schedule(function()
		Wait(3)
		self:Reset()
	end)
	
end

function LocationPhysicsPositionFixScript:Reset()
	self:GetEntity():SetPosition(self.originalPosition)
	self:GetEntity():SetRotation(self.originalRotation)
end

return LocationPhysicsPositionFixScript
