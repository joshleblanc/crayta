local UserPaddleScript = {}

-- Script properties are defined here
UserPaddleScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "leftDown", type = "boolean", editable = false },
	{ name = "rightDown", type = "boolean", editable = false },
	{ name = "paddle", type = "entity", editable = false }
}

--This function is called on the server when this entity is created
function UserPaddleScript:Init()
end

function UserPaddleScript:SetPaddle(paddle) 

	self.properties.paddle = paddle
end

function UserPaddleScript:OnButtonPressed(btn)

	if btn == "right" then 
		self.properties.rightDown = true
	elseif btn == "left" then 
		self.properties.leftDown = true
	end
end

function UserPaddleScript:OnButtonReleased(btn)
	if btn == "right" then 
		self.properties.rightDown = false
	elseif btn == "left" then 
		self.properties.leftDown = false 
	end
end

function UserPaddleScript:ProcessButtons(dt)
	local adjustment = 250 * dt
	local p = self.properties.paddle
	if self.properties.rightDown then 
		p:SetRelativePosition(p:GetRelativePosition() + Vector.New(adjustment, 0, 0))
	elseif self.properties.leftDown then 
		p:SetRelativePosition(p:GetRelativePosition() - Vector.New(adjustment, 0, 0))
	end
end

function UserPaddleScript:OnTick(dt)
	if not self.properties.paddle then return end 
	
	self:ProcessButtons(dt)
end

function UserPaddleScript:LocalOnTick(dt)
	if not self.properties.paddle then return end 

	self:ProcessButtons(dt)
end

return UserPaddleScript
