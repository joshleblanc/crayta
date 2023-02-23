local AutoRunScript = {}

-- Script properties are defined here
AutoRunScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function AutoRunScript:LocalInit()
	self.upCount = 0
end

function AutoRunScript:LocalOnButtonPressed(btn)
print(btn)
	if btn == "forward" then
		self.autoRun = true
		self.upCount = self.upCount + 1
		print(self.upCount)
	else
		self.upCount = 0
		print(self.upCount)
	end
	
	if self.upCount == 2 then
		self:GetEntity():GetUser():SetMoveOverride(Vector2D.New(0,0),Vector2D.New(0,1))
		print("autorun enabled")
	else
		self:GetEntity():GetUser():SetMoveOverride(Vector2D.New(1,1),Vector2D.New(0,0))
		print("resetting")
	end
end

return AutoRunScript
