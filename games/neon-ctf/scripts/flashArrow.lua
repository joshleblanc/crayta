local FlashArrow = {}

-- Script properties are defined here
FlashArrow.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function FlashArrow:Init()
	local num = 0
	self:Schedule(function()
		while true do
			Wait(.5)
			self:GetEntity():SetPosition(self:GetEntity():GetPosition() - Vector.New(0, 0, 50))
			num = num + 1
			if num == 3 then
				num = 0
				self:GetEntity():SetPosition(self:GetEntity():GetPosition() + Vector.New(0, 0, 150))
			end
		end
	end)
end

return FlashArrow
