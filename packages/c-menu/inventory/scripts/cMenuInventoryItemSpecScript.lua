local CMenuInventoryItemSpecScript = {}

function isExaminable(p)
	return p.examinable
end

function isUsable(p)
	return p.usable
end

-- Script properties are defined here
CMenuInventoryItemSpecScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "iconUrl", type = "string" },
	{ name = "usable", type = "boolean" },
	{ name = "onUse", type = "event", visibleIf=isUsable },
	{ name = "description", type = "text" },
	{ name = "examinable", type = "boolean" },
	{ name = "examineText", type = "text", visibleIf=isExaminable },
	{ name = "droppable", type = "boolean" }
}

function CMenuInventoryItemSpecScript:OnUse(user)
	if self.properties.usable then 
		self.properties.onUse:Send(user, self:GetEntity())
	end
end

return CMenuInventoryItemSpecScript
