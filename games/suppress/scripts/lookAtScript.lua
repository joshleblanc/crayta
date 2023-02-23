local LookAtScript = {}

-- Script properties are defined here
LookAtScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "lookAt", type = "entity", editable = false }
}

--This function is called on the server when this entity is created
function LookAtScript:Init()
end

function LookAtScript:HandleTriggerEnter(e)
	self.properties.lookAt = e
end

function LookAtScript:LookAt()
	if self.properties.lookAt and Entity.IsValid(self.properties.lookAt) then 
		local pos = self.properties.lookAt:GetPosition()
		local dir = (self:GetEntity():GetPosition() - pos):Normalize()
		
		self:GetEntity():SetRotation(Rotation.FromVector(dir))
	end
end

function LookAtScript:OnTick()
	self:LookAt()
end

function LookAtScript:ClientOnTick()
	self:LookAt()
end


return LookAtScript
