local RollTrackingScript = {}

-- Script properties are defined here
RollTrackingScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "isRolling", type = "boolean", editable = false },
	{ name = "crystal", type = "entity",},
	{ name = "rollingSounds", type = "soundasset", container = "array"},
	
	
}

--This function is called on the server when this entity is created
function RollTrackingScript:Init()
	
end

function RollTrackingScript:OnRollStart()
	self.properties.isRolling = true
	local rand = math.random(1,2)
	self:GetEntity():PlaySound(self.properties.rollingSounds[rand])
	self.properties.crystal.visible = true
	
end

function RollTrackingScript:OnRollStop()
	self.properties.isRolling = false
	self.properties.crystal.visible = false	
end




return RollTrackingScript
