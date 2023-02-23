local YFixScript = {}

-- Script properties are defined here
YFixScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function YFixScript:Init()
	local location = self:GetEntity():GetUser():FindScriptProperty("locationEntity")
	if location then 
		local yPos = location:FindScriptProperty("yAlignment")
		if yPos then 
			self.yPos = yPos:GetRelativePosition()
		end
	end
end

function YFixScript:OnTick()
	if self.yPos then 
		local pos = self:GetEntity():GetRelativePosition()
		local diff = math.abs(pos.y - self.yPos.y)
		if diff > 0.01 then 
			print("fixing y", self:GetEntity():GetRelativePosition(), self.yPos)
			
			pos.y = self.yPos.y
			self:GetEntity():SetPosition(pos)
		end
	end
end

return YFixScript
