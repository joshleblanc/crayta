local FlyScript = {}

-- Script properties are defined here
FlyScript.Properties = {
	{ name = "entity", type = "entity" },
	{ name = "lightEntity", type = "entity" },
	{ name = "effectEntity", type = "entity" },
	{ name = "lightOffset", type = "vector" },
	{ name = "flying", type = "boolean", default = false, editable = false }
}

function FlyScript:ClientOnTick()
	if not self.properties.flying then return end 
	local pos = self.properties.entity:GetPosition()
	self.properties.lightEntity:SetPosition(pos + self.properties.lightOffset)
	self.properties.effectEntity:SetPosition(pos)
end

function FlyScript:Fly()
	self.properties.flying = true
	self.properties.entity.physicsEnabled = true
	
	local x = math.random() * 500 - 250
	local y = math.random() * 500 - 250
	local z = 750
	
	self.properties.entity:SetVelocity(Vector.New(x, y, z))
end

return FlyScript
