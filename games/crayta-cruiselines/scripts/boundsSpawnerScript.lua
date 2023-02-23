local BoundsSpawnerScript = {}

-- Script properties are defined here
BoundsSpawnerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "template", type = "template" },
	{ name = "onSpawned", type = "event" },
	{ name = "spawned", type = "boolean", default = false, editable = false }
}

--This function is called on the server when this entity is created
function BoundsSpawnerScript:Init()
	print("Bounds Spawner init")
	local children = self:GetEntity():GetChildren()
	if #children == 0 then
		print("Spawning bounds")
		local bounds = GetWorld():Spawn(self.properties.template, Vector.Zero, Rotation.Zero)
		bounds:AttachTo(self:GetEntity())
		print("Bounds Spawned", bounds:GetRelativePosition())
		self.properties.spawned = true
		self.properties.onSpawned:Send()
	else
		self.properties.spawned = true
		self.properties.onSpawned:Send()
	end
end

function BoundsSpawnerScript:ClientInit()
	if self.properties.spawned then
		print("Client init, bounds already spawned")
		self.properties.onSpawned:Send()
	end
end

return BoundsSpawnerScript
