local UserCurrentlyHuntingScript = {}

-- Script properties are defined here
UserCurrentlyHuntingScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserCurrentlyHuntingScript:LocalInit()
	self.widget = self:GetEntity().userCurrentHuntingWidget
end

function UserCurrentlyHuntingScript:SetHunted(user)
	if IsServer() then
		self:SendToLocal("SetHunted", user)
		return
	end
	if user:GetUsername() == GetWorld():GetLocalUser():GetUsername() then
		self.widget.js.data.name = "You"
	else
		self.widget.js.data.name = tostring(user:GetUsername())
	end
	self.widget.js.data.color = user:FindScriptProperty("color")
end

function UserCurrentlyHuntingScript:Show()
	if IsServer() then
		self:SendToLocal("Show")
		return
	end
	self.widget:Show()
end

function UserCurrentlyHuntingScript:Hide()
	if IsServer() then
		self:SendToLocal("Hide")
		return
	end
	self.widget:Hide()
end

return UserCurrentlyHuntingScript
