local FixRotation = {}

function FixRotation:Init()
	self.originalRotation = self:GetEntity():GetRotation()
end

--This is super heavy handed but I couldn't figure out why the timer was rotating
function FixRotation:OnTick()
	self:GetEntity():SetRotation(self.originalRotation)
end

return FixRotation
