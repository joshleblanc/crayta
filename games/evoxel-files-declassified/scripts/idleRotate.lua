local IdleRotate = {}

-- Script properties are defined here
IdleRotate.Properties = {
	-- Example property
	{ name = "startRot", type = "rotation" },
	{ name = "endRot", type = "rotation" },
	{ name = "speed", type = "number" } 
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function IdleRotate:Init()

	local startRot = self.properties.startRot
	local endRot = self.properties.endRot
	
	self:Rotate(startRot, endRot)
end


function IdleRotate:Rotate(startRot, endRot)
	local step = 0
	self:Schedule(function() 
		
		while(step < .99) do
			local dt = Wait()
			step = step + self.properties.speed * dt
			self:GetEntity():SetRotation(Rotation.Lerp(startRot, endRot, step))
		end
		
		self:Rotate(endRot, startRot)
		
	end)
end

return IdleRotate
