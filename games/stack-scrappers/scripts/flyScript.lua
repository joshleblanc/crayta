local FlyScript = {}

-- Script properties are defined here
FlyScript.Properties = {
	{ name = "entity", type = "entity" },
	{ name = "lightEntity", type = "entity" },
	{ name = "effectEntity", type = "entity" },
	{ name = "lightOffset", type = "vector" },
	{ name = "launchX", type = "number", default = 500 },
	{ name = "launchY", type = "number", default = 500 },
	{ name = "launchStrength", type = "number", default = 750 },
	{ name = "flying", type = "boolean", default = false, editable = false }
}

function FlyScript:ClientOnTick()
	if not self.properties.entity then return end 
	if not self.properties.flying then return end 
	
	local pos = self.properties.entity:GetPosition()
		
	if self.properties.lightEntity then
		self.properties.lightEntity:SetPosition(pos + self.properties.lightOffset)
	end
	
	if self.properties.effectEntity then
		self.properties.effectEntity:SetPosition(pos)
	end
	
end

function FlyScript:Reset()
	self.properties.flying = false
	self.properties.entity.physicsEnabled = false
end

function FlyScript:Fly()
	self.properties.flying = true
	self.properties.entity.physicsEnabled = true
	
	local x = math.random() * self.properties.launchX - (self.properties.launchX / 2)
	local y = math.random() * self.properties.launchY - (self.properties.launchY / 2)
	local z = self.properties.launchStrength
	
	self.properties.entity:SetVelocity(Vector.New(x, y, z))
	self.properties.entity:SetAngularVelocity(Rotation.New(math.random(), math.random(), math.random()))
	
	-- self.properties.flying must stay true to maintain the light entity
	
end

return FlyScript
