local EdibleScript = {}

-- Script properties are defined here
EdibleScript.Properties = {
	-- Example property
	{name = "eatenSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function EdibleScript:Init()
	self.eaten = false
end


function EdibleScript:OnInteract()
	if self.eaten == false then
		self.eaten = true
		self:Schedule(function()
			self:GetEntity():PlaySound(self.properties.eatenSound)
			self:GetEntity().visible = false
			Wait(60)
			self:GetEntity().visible = true
			self.eaten = false
		end)
	end
end
return EdibleScript
