local SpiralAttackScript = {}

-- Script properties are defined here
SpiralAttackScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "orb", type = "template" },
	{ name = "attacking", type = "boolean", default = false, editable = false },
	{ name = "objectPool", type = "entity" },
}

--This function is called on the server when this entity is created
function SpiralAttackScript:Init()
	self.objectPool = self.properties.objectPool
end

function SpiralAttackScript:Attack(user)
	self.properties.attacking = true
	local steps = 50
	local distance = 10
	local inc = 360 / steps
	self:Schedule(function()
		for i=0,steps do
			local rot = Rotation.New(0, i * inc, 0)
			local pos = self:GetEntity():GetPosition()
			local orb = self.objectPool.objectPoolScript:GetAvailableObj(self.properties.orb)
			orb:SetPosition(pos)
			orb:SetRotation(rot)
			--local orb = GetWorld():Spawn(self.properties.orb, pos, rot)
			orb:SendToScripts("SetVelocity", orb:GetForward() * -1000)
			orb:SendToScripts("SetOwner", self:GetEntity())
			Wait()
		end
		self.properties.attacking = false
	end)
end

return SpiralAttackScript
