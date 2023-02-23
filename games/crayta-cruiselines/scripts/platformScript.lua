local PlatformScript = {}

-- Script properties are defined here
PlatformScript.Properties = {
	-- Example property
	{name = "popSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function PlatformScript:Init()
	self.safe = false
	self.entity = self:GetEntity()
	self.initialized = true
	self.initialPosition = self.entity:GetPosition()
	self.loweredPosition = self.entity:GetPosition() - Vector.New(0, 0, 400)
	
	self.entity:SetPosition(self.loweredPosition)
end

function PlatformScript:OnCollision(entity)
	if not entity:IsA(Character) then return end 
	if not entity:IsAlive() then return end 
	if self.safe then return end 
	self:GetEntity():PlaySound(self.properties.popSound)
	self.entity:PlayTimeline(
		0, self.entity:GetPosition(),
		1, self.loweredPosition
	)
	--self.entity.collisionEnabled = false
	--self.entity.visible = falese
end

function PlatformScript:SetSafe()
	self.safe = true
end

function PlatformScript:End()
	self.entity:PlayTimeline(
		0, self.entity:GetPosition(),
		3, self.loweredPosition
	)
	self.safe = false
end

function PlatformScript:Start()
	self.entity:PlayTimeline(
		0, self.loweredPosition,
		3, self.initialPosition
	)
	--self.entity.collisionEnabled = true
	--self.entity.visible = true
	self.safe = false
end

return PlatformScript
