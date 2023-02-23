local AiScript = {}

-- Script properties are defined here
AiScript.Properties = {
	-- Example property
	{name = "AllStacksGroup", type = "entity"},
	{name = "aiActive", type = "boolean", default = false, editable = false},
}

--This function is called on the server when this entity is created
function AiScript:Init()
	self.allStacks = self.properties.AllStacksGroup:GetChildren()
end

function AiScript:ActivateAI()
	self.properties.aiActive = true
end

function AiScript:FindClosestStack()
	if self.properties.aiActive then
		--Store our position and create temp distance var
		local distanceFromSafeStack = 50000
		local pos = self:GetEntity():GetPosition()
		local safeStack
		
		for i=1,#self.allStacks do
			local stack = self.allStacks[i]
			local script = stack:FindScript("TrainShellScript",true)
			if script.properties.numOfShells > 1 then
				local dist = Vector.Distance(pos, stack:GetPosition())
				if dist < distanceFromSafeStack then
					distanceFromSafeStack = dist
					safeStack = stack
				end
			
			else
				print("Not a safe stack")
			end
		end
		
		if safeStack then
			return safeStack
		end
	end
end


function AiScript:OnTick(dt)
	local entity = self:GetEntity()
	local stack = self:FindClosestStack()
	if stack then
			local direction = stack:GetPosition() - self:GetEntity():GetPosition()
			direction = direction:Normalize() * 500
			self:GetEntity():SetVelocity(direction)
			
	end
end




--Goals
--Collect Gears
	--Find Closest Safe Stack of 2 or more
		-- Move within X (1500?) of stack of 2
		-- Find Gears closest to stack of 2
		-- Move to collect gears
		-- if hunted, retreat to stack
			--Enter stack via closest door.
		
		


-- if more than X away from closest stack of 2 or more, move closer to stack of 2
  -- find closest gears
--If hunted -- find closest stack of 2 or more
--move toward closest stack
--move toward closest door entrance


return AiScript
