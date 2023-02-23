local KillFeedScript = {}

-- Script properties are defined here
KillFeedScript.Properties = {
	{ name = "critIconType", type = "string", options = { "url", "svg" }, default = "url" },
	{ name = "fallbackIconType", type = "string", options = { "url", "svg" }, default = "url" },
	{ name = "critIcon", type = "string", visibleIf=function(p) return p.critIconType == "svg" end },
	{ name = "fallbackIcon", type = "string", visibleIf=function(p) return p.critIconType == "svg" end },
	{ name = "critIconUrl", type = "string", visibleIf=function(p) return p.critIconType == "url" end },
	{ name = "fallbackIconUrl", type = "string", visibleIf=function(p) return p.fallbackIconType == "url" end },
}

function KillFeedScript:LocalInit()
	self.killFeedIcons = self:GetEntity():FindAllScripts("killFeedIconScript")

	self.notificationWidget = self:GetEntity().killFeedWidget
	self.notificationWidget.js:CallFunction("Clear")
end

function KillFeedScript:AddToKillFeed(killer, killed, weapon, crit)
	if IsServer() then 
		self:SendToLocal("AddToKillFeed", killer, killed, weapon, crit)
	else 
		local icon = self:FindIcon(weapon)
		
		
		if not icon then 
			if self.properties.fallbackIconType == "svg" then 
				icon = self.properties.fallbackIcon
			else 
				icon = FormatString("<img src=\"{1}\">", self.properties.fallbackIconUrl)
			end
			
		end
		
		local msg = FormatString("<div>{1}</div> {2} <div>{3}</div>", self:FindUsername(killer), icon, self:FindUsername(killed))

		self.notificationWidget.js:CallFunction("AddNotification", msg, true)
	end
end

function KillFeedScript:FindUsername(entity)
	if entity and entity.GetUser then 
		return entity:GetUser():GetUsername()
	end
	return ""
end

function KillFeedScript:FindIcon(weapon)
	for _, iconScript in ipairs(self.killFeedIcons) do 
		if weapon:GetTemplate() == iconScript.properties.weapon then 
			return iconScript:GetIcon()
		end
	end
end

return KillFeedScript
