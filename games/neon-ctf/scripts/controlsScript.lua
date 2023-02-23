local ControlsScript = {}

-- Script properties are defined here
ControlsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ControlsScript:LocalOnButtonPressed(button)
	if button ~= "secondary" and button ~= "primary" and button ~= "jump" and button ~= "crouch" and button ~= "left" and button ~= "right" and button ~= "forward" and button ~= "backward" then
		self:Show()
	end
	if button == "secondary" then
		self:Hide()
	end
end

function ControlsScript:Show()
	if IsServer() then
		self:GetEntity():SendToLocal("Show")
		return
	end
	if self.timer then
		self:Cancel(self.timer)
	end
	self:GetEntity().controlsWidget:Show()
	self.timer = self:Schedule(function()
		Wait(3)
		self:Hide()
	end)
end

function ControlsScript:Hide()
	if IsServer() then
		self:GetEntity():SendToLocal("Hide")
		return
	end
	if self.timer then
		self:Cancel(self.timer)
	end
	self:GetEntity().controlsWidget:Hide()
end

return ControlsScript
