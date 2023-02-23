local DeskScript = {}

-- Script properties are defined here
DeskScript.Properties = {
	-- Example property
	{name = "chair", type = "entity"},
}

--This function is called on the server when this entity is created
function DeskScript:Init()
	self.moving = false
end

function DeskScript:OnTriggerEnter(player)
	if player:IsA(Character) and self.moving == false then
		self.moving = true
		self:Schedule(function()
			self.properties.chair:AlterRelativePosition(Vector.New(0,200,0),2)
			Wait(3)
			self.properties.chair:AlterRelativePosition(Vector.New(0,100,0),2)
			self.moving = false
		end)
	end
end

return DeskScript
