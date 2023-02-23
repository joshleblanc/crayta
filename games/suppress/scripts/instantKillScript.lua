local InstantKillScript = {}

-- Script properties are defined here
InstantKillScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function InstantKillScript:Init()
end

function InstantKillScript:OnTriggerEnter(player)
	if player:IsA(Character) then
		local pos = self:GetEntity():GetPosition()
		player:ApplyDamage(999999, (pos - player:GetPosition()):Normalize(), self:GetEntity())
	end
end

return InstantKillScript
