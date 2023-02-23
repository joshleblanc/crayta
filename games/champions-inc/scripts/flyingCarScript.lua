local FlyingCarScript = {}

-- Script properties are defined here
FlyingCarScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function FlyingCarScript:Init()
	self:Schedule(function()
		self.originalPos = self:GetEntity():GetRelativePosition()
		 self:ChoosePath()
	end)
end

function FlyingCarScript:ChoosePath()
		Wait()
		local z = math.random(-3500,3500)
		local y = math.random(-15000,15000)
		local distanceToTravel = 60000
		self.start = self:GetEntity():GetPosition() + Vector.New(0,y,z)
		self.dest = self.start + Vector.New(60000,0,0)
		
		GetWorld():Raycast(self.start, self.dest, {}, function(hitEntity,hitResult)
			if hitEntity then
				return false
				else return true
			end
		end)

end

function FlyingCarScript:FlyPath(start,dest)
print("Traveling")
	Wait(self:GetEntity():PlayRelativeTimeline(
		0, start,
		30, dest
		)
	)
	self:Reset()
end

function FlyingCarScript:OnTick(dt)
	self:GetEntity():GetPosition()
end


function FlyingCarScript:Reset()
	self:GetEntity():SetRelativePosition(self.originalPos)
end

return FlyingCarScript
