local DialogScript = {}

-- Script properties are defined here
DialogScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "welcome", type = "text" },
	{ name = "instructions", type = "text", container = "array" },
	{ name = "flavor", type = "text", container = "array" },
	{ name = "death", type = "text", container = "array" },
	{ name = "wait", type = "text" }
}

--This function is called on the server when this entity is created
function DialogScript:LocalInit()
	self:SetText(self.properties.welcome)
	self.instructionTimes = { 1, 10, 20, 30, 60 }
	self.instructionIndex = 1
end

function DialogScript:SetText(text) 
	if IsServer() then
		self:SendToLocal("SetText", text)
		return
	end
	self:GetEntity():FindWidget("dialog").js.data.text = text
end

function DialogScript:Wait()
	self:SetText(self.properties.wait)
end

function DialogScript:Start()
	if not self:GetEntity():IsLocal() or self.handle then
		return
	end
	print("Starting")
	local instructions = #self.properties.instructions
	local time = 0
	local messages = {}
	self.instructionIndex = 1
	self.handle = self:Schedule(function()
		while(true) do
			local dt = Wait()
			time = time + dt
			
			local floorTime = math.ceil(time)
			
			if self.instructionIndex <= 5 then
				local instructionDelay = self.instructionTimes[self.instructionIndex]

				if floorTime % instructionDelay == 0 then
					self:SetText(self.properties.instructions[self.instructionIndex])
					self.instructionIndex = self.instructionIndex + 1
				end
			else
				if floorTime % 25 == 0 then
					if not messages[floorTime] then
						local r = math.random(1, #self.properties.flavor)
						messages[floorTime] = self.properties.flavor[r]
						self:SetText(messages[floorTime])
					end
				end
			end
		end 
	end)
end

function DialogScript:End()
	if not self:GetEntity():IsLocal() then
		self:SendToLocal("End")
		return
	end
	
	if self.handle then
		self:Cancel(self.handle)
		self.handle = nil
	end

	local r = math.random(1, #self.properties.death)
	self:SetText(self.properties.death[r])

end

return DialogScript
