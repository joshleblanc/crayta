local FreeMoneyScript = {}

-- Script properties are defined here
FreeMoneyScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function FreeMoneyScript:Init()
end

function FreeMoneyScript:OnInteract(player)

	player:GetUser().userMoneyScript:AddMoney(100000)
end

return FreeMoneyScript
