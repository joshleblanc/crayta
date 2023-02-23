local NumberScript = {}

-- Script properties are defined here
NumberScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function NumberScript:ClientInit()
	self.widget = self:GetEntity().numberWidget
end

function NumberScript:SetNumber(num)
	self.widget.js.data.num = num
end

return NumberScript
