local PlayerOilSlickScript = {}

-- Script properties are defined here
PlayerOilSlickScript.Properties = {
	-- Example property
	{ name = "inOilSlick", type = "boolean", default = false, editable = false },
	{ name = "oilSlickSpeedMultiplier", type = "number", default = 0.5 }
}

function PlayerOilSlickScript:EnterOilSlick()
	self.properties.inOilSlick = true
end

function PlayerOilSlickScript:ExitOilSlick()
	self.properties.inOilSlick = false
end

return PlayerOilSlickScript
