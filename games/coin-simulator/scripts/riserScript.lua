local RiserScript = {}

-- Script properties are defined here
RiserScript.Properties = {
	-- Example property
	{ name = "height", type = "number" },
	{ name = "offset", type = "number" }
}

--This function is called on the server when this entity is created
function RiserScript:Init()
	local pos = self:GetEntity():GetPosition()
	local f = -(self.properties.height - self.properties.offset - 2)
	self:GetEntity():SetPosition(Vector.New(pos.x, pos.y, math.random(f, self.properties.offset)))
	
	local dir = math.random(0, 1)
	self:Schedule(function()
		local bottom = f
		local top = self.properties.offset
		local target
		if dir == 0 then
			target = bottom
		else
			target = top
		end
		
		while true do
			local newPos = self:GetEntity():GetPosition()
			newPos.z = target
			
			local time = (10 * math.random()) + 3
			Wait(self:GetEntity():PlayTimeline(
				0, self:GetEntity():GetPosition(), "EaseInOut",
				time, newPos, "EaseInOut"
			))
			
			if dir == 0 then
				target = top
				dir = 1
			else
				target = bottom
				dir = 0
			end
		end
			
	end)
end

return RiserScript
