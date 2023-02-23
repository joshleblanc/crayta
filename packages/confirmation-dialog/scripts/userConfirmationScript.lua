local UserConfirmationScript = {}

-- Script properties are defined here
UserConfirmationScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "changeSound", type = "soundasset" },
	{ name = "selectSound", type = "soundasset" }
}

--This function is called on the server when this entity is created
function UserConfirmationScript:LocalInit()
	self.widget = self:GetEntity().userConfirmationWidget
end

function UserConfirmationScript:Show()
	if IsServer() then
		self:SendToLocal("Show")
		return
	end
	
	print("Showing widget")
	
	self:GetEntity().userConfirmationWidget:Show()
end

function UserConfirmationScript:Select()
	self:GetEntity():PlaySound2D(self.properties.changeSound)
end

function UserConfirmationScript:Hide()
	if IsServer() then
		self:SendToLocal("Hide")
		return
	end
	
	print("Hiding widget")
	self:GetEntity().userConfirmationWidget:Hide()
end

function UserConfirmationScript:Prompt(msg, options, callback)
	print("Showing prompt")
	self.widget:CallFunction("Reset") 
	for k,v in ipairs(options) do
		self.widget:CallFunction("AddOption", v.name, v.value)
	end
	self.callback = callback
	self:GetEntity().userConfirmationWidget.js.data.message = msg
	self.widget:CallFunction("SelectDefault")
	self:Show()
end

function UserConfirmationScript:LocalConfirm(msg, callback)
	self:Prompt(msg, { { name = "Yes", value = true }, { name = "No", value = false }}, callback)
end

function UserConfirmationScript:Respond(response)
	print("Respond called", self.callback)
	
	if self.callback then
		self:GetEntity():PlaySound2D(self.properties.selectSound)
		self:Hide()
		
		local cb = self.callback 
		self.callback = nil
		cb(response)
	end
end

return UserConfirmationScript
