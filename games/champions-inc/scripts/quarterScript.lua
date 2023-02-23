local QuarterScript = {}

-- Script properties are defined here
QuarterScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function QuarterScript:Init()
end

function QuarterScript:AssignHero(hero)
	local widget = self:GetEntity():FindWidget("quartersSignWidget", true)
	local template = GetWorld():FindTemplate(hero.templateName)

	widget.properties.signTitle = template:FindScriptProperty("name")
	if hero.mia then 
		widget.properties.signText = Text.Format("Missing in Action")
	else
		widget.properties.signText = Text.Format("")
	end
end

return QuarterScript
