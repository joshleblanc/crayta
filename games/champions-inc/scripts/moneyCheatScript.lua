local MoneyCheatScript = {}

-- Script properties are defined here
MoneyCheatScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "amount", type = "number", default = 10000 }
}

--This function is called on the server when this entity is created
function MoneyCheatScript:Init()
end

function MoneyCheatScript:GiveMoney()
	self:GetEntity():SendToScripts("AddMoney", self.properties.amount)
end

return MoneyCheatScript
