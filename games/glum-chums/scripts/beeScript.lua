local BeeScript = {}

-- Script properties are defined here
BeeScript.Properties = {
}

--This function is called on the server when this entity is created
function BeeScript:Init()
	
end

function BeeScript:OnDamage(amt, from, hitResult)
	local newBee = GetWorld():Spawn(self:GetEntity():GetTemplate(), Vector.Zero, Rotation.Zero)
	newBee.wanderScript:Disable()
	
	self:GetEntity():SendToScripts("Equip", from:GetUser(), newBee)
	
	self:GetEntity():Destroy()
	
	from:GetUser():SendXPEvent("catch", { what = "bee" })
end

return BeeScript
