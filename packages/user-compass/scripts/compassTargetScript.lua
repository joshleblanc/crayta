local CompassTargetScript = {}

-- Script properties are defined here
CompassTargetScript.Properties = {
	{ name = "id", type = "string", tooltip = "ID will be generated if this property is left blank" },
	{ name = "name", type = "string" },
	{ name = "entity", type = "entity" },
	{ name = "indicator", type = "string", options = { "Dot", "Square", "Font Awesome Icon", "Google Material Icon", "Image" }, default = "Dot" },
	{ name = "codePoint", type = "string", visibleIf = function(a) return a.indicator == "Font Awesome Icon" or a.indicator == "Google Material Icon" end },
	{ name = "imageUrl", type = "string", visibleIf = function(a) return a.indicator == "Image" end },
	{ name = "color", type = "color", visibleIf = function(a) return a.indicator ~= "Image" end },
	{ name = "fadeIcon", type = "boolean", tooltip = "Fade icon when it's near the edge of the compass" },
	{ name = "pulse", type = "boolean", default = false },
	{ name = "showDistance", type = "boolean", default = true },
	{ name = "alwaysShow", type = "boolean", default = true },
	{ name = "minimumDistance", type = "number", default = 1000, visibleIf = function(p) return not p.alwaysShow end, tooltip = "At what distance the icon should appear on the compass, in cm" },
	{ name = "displayWorldIndicator", type = "boolean", default = false, group = "worldIndicator" },
	{ name = "alwaysDisplayWorldIndicator", type = "boolean", default = false, group = "worldIndicator" },
	{ name = "keepWorldIndicatorOnScreen", type = "boolean", default = false, group = "worldIndicator" },
	{ name = "worldIndicatorMinimumDistance", type = "number", default = 1000, visibleIf = function(p) return p.displayWorldIndicator and not p.alwaysDisplayWorldIndicator end, group = "worldIndicator" },
}

function CompassTargetScript:Init() 
	if string.len(self.properties.id) == 0 then
	 	local id = ""
		for i=1,10 do
			id = id .. string.char(math.random(97, 122))
		end
	
		self.properties.id = id 
	end
end

function CompassTargetScript:IsVisible(distance)
	return self.properties.alwaysShow or distance <= self.properties.minimumDistance
end

return CompassTargetScript
