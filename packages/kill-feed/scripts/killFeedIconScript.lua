local KillFeedIconScript = {}

-- Script properties are defined here
KillFeedIconScript.Properties = {
	-- Example property
	{ name = "weapon", type = "template" },
	{ name = "iconType", type = "string", options = { "template", "svg", "url" }, default = "template" },
	{ name = "icon", type = "string", visibleIf=function(p) return p.iconType == "svg" end },
	{ name = "iconUrl", type = "string", visibleIf=function(p) return p.iconType == "url" end },
}

--This function is called on the server when this entity is created
function KillFeedIconScript:Init()
end

function KillFeedIconScript:GetIcon()
	if self.properties.iconType == "svg" then 
		return self.properties.icon
	elseif self.properties.iconType == "url" then 
		return FormatString("<img src=\"{1}\">", self.properties.iconUrl)
	else
		local url = self:GetIconFromTemplate(self.proeprties.weapon)
		return FormatString("<img src=\"{1}\">", url)
	end
end

function KillFeedIconScript:GetIconFromTemplate(template)
	if not template then
		return ""
	end
	
	local iconAsset = template:FindScriptProperty("iconAsset")
	
	if iconAsset then
		return iconAsset:GetIcon()
	else 
		return ""
	end
end

return KillFeedIconScript
