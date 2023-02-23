local CMenuScript = {}

function enableCursorOnButtonPress(p)
	return p.enableCursorOnButtonPress
end

-- Script properties are defined here
CMenuScript.Properties = {
	{ name = "displayMenu", type = "boolean", default = true },
	{ name = "enableCursorOnButtonPress", type = "boolean", default = true },
	{ name = "cursorEnableButton", type = "string", default = "extra5", visibleIf=enableCursorOnButtonPress },
	{ name = "showInstructions", type = "boolean", default = true, visibleIf=enableCursorOnButtonPress },
	{ name = "overrideColors", type = "boolean", default = true },
}

--This function is called on the server when this entity is created
function CMenuScript:LocalInit()
	self.widget = self:GetEntity().cMenuWidget
	self.menuOptions = self:GetEntity():FindAllScripts("cMenuOptionScript")
	
	table.sort(self.menuOptions, function(a,b) 
		if a.properties.index and b.properties.index then 
			return a.properties.index > b.properties.index
		elseif a.properties.index then 
			return true
		elseif b.properties.index then
			return false
		else
			return false
		end
	end)
	
	self.widget.requiresCursor = false 
	
	if self.properties.displayMenu then 
		self.widget.visible = true
	else
		self.widget.visible = false
	end
	
	if self.properties.enableCursorOnButtonPress and self.properties.showInstructions then 
		local button = "({" .. FormatString("{1}-icon-raw", self.properties.cursorEnableButton) .. "})"
		self.widget.properties.instructions = Text.Format("{1} Toggle Cursor", button)
	else
		self.widget.properties.instructions = Text.Format("")
	end
	
	
	local menuOptions = {}
	for _, option in ipairs(self.menuOptions) do 
		if option.properties.showOnMenuBar then
			table.insert(menuOptions, option:ToTable())
		end
	end
	
	self.widget.js.data.options = menuOptions
	
	if self.properties.overrideColors then 
		for _, menuOption in ipairs(self.menuOptions) do 
			menuOption:GetWidget().properties.titleColor = self.widget.properties.titleColor
			menuOption:GetWidget().properties.backgroundColor = self.widget.properties.backgroundColor
			menuOption:GetWidget().properties.borderColor = self.widget.properties.borderColor
			menuOption:GetWidget().properties.font = self.widget.properties.font
		end
	end
end

function CMenuScript:HideBar() 
	self.widget.visible = false
end

function CMenuScript:ShowBar()
	self.widget.visible = true
end

function CMenuScript:OpenMenuOption(menuOption)
	local option = self:FindOption(menuOption)
	
	if not option then return end 
	
	option:ShowMenuOption()
end

function CMenuScript:CloseMenuOption(menuOption)
	local option = self:FindOption(menuOption)
	
	if not option then return end 
	
	option:HideMenuOption()
	
	if not self:IsSomethingOpen() then 
		self:DisableCursor()
	end
end

function CMenuScript:IsSomethingOpen() 
	for _, menuOption in ipairs(self.menuOptions) do
		if menuOption.widget.visible then 
			return true
		end
	end
	
	return false
end

function CMenuScript:ToggleMenuOption(menuOption)
	local option = self:FindOption(menuOption)
	
	if not option then return end 
	
	option:ToggleVisibility()
	
	if not self:IsSomethingOpen() then 
		self:DisableCursor()
	end
end

function CMenuScript:FocusMenuOption(menuOption)
	--[[
	for _, menuOption in ipairs(self.menuOptions) do 
		menuOption.widget.order = 2
		if menuOption.properties.id == menuOption then 
			menuOption.widget.order = 1
		end
	end
	]]--
end

function CMenuScript:LocalOnButtonPressed(btn)
	if self.properties.enableCursorOnButtonPress and btn == self.properties.cursorEnableButton then 
		self:EnableCursor()
	end
end

function CMenuScript:EnableCursor()
	self:Schedule(function()
		Wait()
		self.widget.requiresCursor = true
	end)
	
end

function CMenuScript:DisableCursor()
	self.widget.requiresCursor = false
	self:CloseAllMenuOptions()
end

function CMenuScript:CloseAllMenuOptions()
	for _, option in ipairs(self:GetMenuOptions()) do 
		option:HideMenuOption()
	end
end

function CMenuScript:FindOption(name)
	for _, option in ipairs(self:GetMenuOptions()) do 
		if option.properties.name == name then
			return option
		end
	end
	
	return nil
end

function CMenuScript:GetMenuOptions()
	if not self.menuOptions then 
		self:LocalInit()
	end
	return self.menuOptions
end

function CMenuScript:FindOptionByWidget(widget)
	for _, option in ipairs(self:GetMenuOptions()) do 
		if option.properties.widget == widget then
			return option
		end
	end
	
	return nil
end

return CMenuScript
