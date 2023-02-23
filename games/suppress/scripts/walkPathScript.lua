local WalkPathScript = {}

-- Script properties are defined here
WalkPathScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "path", type = "entity", container = "array" },
	{ name = "speed", type = "number", default = 100 },
	{ name = "loop", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function WalkPathScript:Init()
	self.index = 1
	self.inc = 1
	
	if #self.properties.path > 0 then 
		self:Move()
	end
end

function WalkPathScript:Move()
	self:Schedule(function()
		local pos = self:GetEntity():GetPosition()
		local dest = self.properties.path[self.index]:GetPosition()
		
		local dist = Vector.Distance(pos, dest)
		local time = dist / self.properties.speed
		local timeToMove = self:GetEntity():PlayTimeline(
			0, pos, --self:GetEntity():GetRotation(),
		--	time / 10, Vector.Lerp(pos, dest, 0.1), Rotation.FromVector((dest - pos):Normalize()),
			time, dest
		)
		Wait(timeToMove)
		
		self.index = self.index + self.inc
		
		if self.properties.loop then 
			if self.index > #self.properties.path then 
				self.index = 1
			elseif self.index < 1 then
				self.index = #self.properties.path
			end
		else 
			if self.index == #self.properties.path or self.index == 1 then 
				self.inc = -self.inc
			end
		end
		
		
		if self.index == 0 then 
			self.inc = -self.inc
		end
		
		if self.index < 1 then 
			self.index = 1
		end
		
		if self.index > #self.properties.path then 
			self.index = #self.properties.path
		end
		
		self:Move()
	end)
end

return WalkPathScript
