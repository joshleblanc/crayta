local MovementTestScript = {}

-- Script properties are defined here
MovementTestScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "camera", type = "entity" }
}

--This function is called on the server when this entity is created
function MovementTestScript:Init()
end

function MovementTestScript:OnButtonPressed(btn)
	
	if btn == "extra2" then
		print("Setting Forward")
		self:GetEntity():SetCamera(self.properties.camera)
		self:GetEntity():SetMoveOverride(Vector2D.Zero, Vector2D.New(0, 1))
		self:GetEntity():GetPlayer():SetForward(Vector.New(math.random(), math.random(), 0))
		
	end
end

return MovementTestScript
