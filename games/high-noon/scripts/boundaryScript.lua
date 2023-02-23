local BoundaryScript = {}

-- Script properties are defined here
BoundaryScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function BoundaryScript:Init()
end

function BoundaryScript:OnCollision(player)
	if player:IsA(Character) and player:IsValid() then
		local text = "Do not try to run away, coward! Stay in the gated area!"
		player:GetUser():SendToScripts("Shout",text)
	end
end

return BoundaryScript
