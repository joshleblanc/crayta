local TrainStackReset = {}

-- Script properties are defined here
TrainStackReset.Properties = {
	-- Example property
	{name = "fullStackTemplate", type = "template"},
	{name = "spawnChance", type = "number", default = 1}
}

function TrainStackReset:Spawn()
	self:Reset()
	if math.random() <= self.properties.spawnChance then
		local entity = GetWorld():Spawn(self.properties.fullStackTemplate, self:GetEntity())
		entity:AttachTo(self:GetEntity())
		entity:SetRelativePosition(Vector.Zero)
		entity:SetRelativeRotation(Rotation.Zero)
	end
end

function TrainStackReset:Reset()
	local children = self:GetEntity():GetChildren()
	
	for i=1,#children do 
		children[i]:Destroy()
	end
end

return TrainStackReset
