local MoneyBagScript = {}

-- Script properties are defined here
MoneyBagScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function MoneyBagScript:Init()
end


function MoneyBagScript:Collected(player)
	if player:IsA(Character) then
		GetWorld():BroadcastToScripts("MoneyFound",player,self:GetEntity())
	end
end


return MoneyBagScript
