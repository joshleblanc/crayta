local CMenuNotificationsScript = {}

-- Script properties are defined here
CMenuNotificationsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function CMenuNotificationsScript:LocalInit()
	self.widget = self:GetEntity().cMenuNotificationsWidget
end

--[[
  imageUrl: string 
  title: string 
  subtitle: string
  quantity: number
  accent: color string (rgba(0,0,0,0), #000000, etc)
]]--
function CMenuNotificationsScript:AddNotification(dataOrMsg, maybeValues) 
	if IsServer() then 
		self:SendToLocal("AddNotification", dataOrMsg, maybeValues)
		return
	end
	
	local data = dataOrMsg
	if type(dataOrMsg) == "string" then -- Backwards compatibility with the notifications package
		local msg = maybeValues and dataOrMsg:Format(maybeValues) or dataOrMsg
		data = {
			title = msg
		}
	end
	
	self.widget:CallFunction("addNotification", data);
end

return CMenuNotificationsScript
