local PlayerColorCircleScript = {}

-- Script properties are defined here
PlayerColorCircleScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created

function PlayerColorCircleScript:ClientInit()
	self.widget = self:GetEntity().playerColorCircleWidget
	self:Schedule(function()
		local done = false
		while not done do
			local user = self:GetEntity():GetParent():GetUser()
			local color = user:FindScriptProperty("color")
			if color then
				self:SetColor(color)
				done = true
			end
			Wait()
		end
	end)
end

function PlayerColorCircleScript:ClientOnTick()
	--self:SetColor(self:GetEntity():GetParent():GetUser().userColorCircleScript.properties.color)
end

function PlayerColorCircleScript:SetColor(color)
	if IsServer() then
		self:SendToAllClients("SetColor", color)
		return
	end
	
	self.widget.js.data.color = color
end

return PlayerColorCircleScript
