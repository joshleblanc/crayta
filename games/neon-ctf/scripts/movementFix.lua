local MovementFix = {}

-- Script properties are defined here
MovementFix.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "lookingRight", type = "boolean" },
	{ name = "lookingLeft", type = "boolean" },
	{ name = "previousButton", type = "string", editable = false } 
}

function MovementFix:ClientOnTick()
	self:Fix()
end

function MovementFix:OnTick()
	self:Fix()
end

function MovementFix:Fix() 
	local offset = self:GetEntity().cameraYaw
	if self.properties.lookingRight then
		self:GetEntity():SetRotation(Rotation.New(0, 90 - offset, 0))
	elseif self.properties.lookingLeft then
		self:GetEntity():SetRotation(Rotation.New(0, -90 - offset, 0))
	end
end

function MovementFix:Restore()
	if not IsServer() then
		self:GetEntity():SendToServer("Restore")
		return
	end
	if self.properties.previousButton == "right" then
		self.properties.lookingLeft = false
		self.properties.lookingRight = true
	end
	if self.properties.previousButton == "left" then
		self.properties.lookingLeft = true
		self.properties.lookingRight = false
	end
end

function MovementFix:OnButtonPressed(button)
	if button == "right" then
		self.properties.lookingLeft = false
		self.properties.lookingRight = true
		self.properties.previousButton = button
	end
	if button == "left" then
		self.properties.lookingLeft = true
		self.properties.lookingRight = false
		self.properties.previousButton = button
	end
	
end

function MovementFix:AdjustDirection(dir)
	if not IsServer() then
		self:GetEntity():SendToServer("AdjustDirection", dir)
		return
	end
	if self:GetEntity().cameraYaw == 0 then -- lobby
		dir.y = dir.y * -1
	end
	if dir.y < 0 then
		self.properties.lookingLeft = true
		self.properties.lookingRight = false
	else
		self.properties.lookingRight = true
		self.properties.lookingLeft = false
	end
end

return MovementFix
