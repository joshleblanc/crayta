local DayChangeNotifierScript = {}

DayChangeNotifierScript.Properties = {

}

function DayChangeNotifierScript:OnNight()
	self:GetEntity():SendToScripts("ShowLocation", { label = "Search for gold and ammo", title = "The sun sets..." })
end

function DayChangeNotifierScript:OnDay()
	self:GetEntity():SendToScripts("ShowLocation", { label = "Hunt down your enemies; Steal their gold.", title = "Dawn of a new day" })
end

return DayChangeNotifierScript
