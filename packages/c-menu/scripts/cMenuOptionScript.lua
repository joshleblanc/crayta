local CMenuOptionScript = {}

-- Script properties are defined here
CMenuOptionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "string" },
	{ name = "icon", type = "string" },
	{ name = "widget", type = "widgetasset" },
	{ name = "onOpen", type = "event" },
	{ name = "onClose", type = "event" },
	{ name = "index", type = "number", default = 0 },
	{ name = "openOnButtonPress", type = "boolean", default = false },
	{ name = "buttonToOpen", type = "string", visibleIf=function(p) return p.openOnButtonPress end },
	{ name = "showOnMenuBar", type = "boolean", default = true },
	{ name = "permanent", type = "boolean", default = false },
}

--This function is called on the server when this entity is created
function CMenuOptionScript:LocalInit()
	self.widget = self:GetEntity():FindWidget(self.properties.widget)
	
	if self.properties.permanent then 
		self.widget.visible = true
	else
		self.widget.visible = false
	end

end

function CMenuOptionScript:GetWidget()
	if self.widget then 
		return self.widget
	end
	self.widget = self:GetEntity():FindWidget(self.properties.widget)
	return self.widget
end

function CMenuOptionScript:LocalOnButtonPressed(btn)
	if self.properties.openOnButtonPress and btn == self.properties.buttonToOpen then 
		self:ShowMenuOption()
	end
end

function CMenuOptionScript:ToggleVisibility()
	if self.widget.visible then 
		self:HideMenuOption()
	else 
		self:ShowMenuOption()
	end
end

function CMenuOptionScript:ShowMenuOption()
	if not self.widget.visible then 
		self.widget.requiresCursor = true
		self.widget.visible = true
		self.properties.onOpen:Send()
	end
	
end

function CMenuOptionScript:HideMenuOption()
	if self.widget.visible and not self.properties.permanent then 
		print("Hiding")
		self.widget.visible = false
		self.properties.onClose:Send()
	end
	
end

function CMenuOptionScript:ToTable() 
	return {
		name = self.properties.name,
		icon = self.properties.icon
	}
end

return CMenuOptionScript
