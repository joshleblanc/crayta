local DectectorTrigger = {}

-- Script properties are defined here
DectectorTrigger.Properties = {
	-- Example property
	{name = "detectorsound", type = "soundasset"},
	{name = "greenLight", type = "entity"},
}

--This function is called on the server when this entity is created
function DectectorTrigger:Init()
	self.on = false
end

function DectectorTrigger:OnTriggerEnter(player)
	self:Schedule(function()
		if self.on == false then
			self.on = true
			self.properties.greenLight.visible = true
			self:GetEntity():PlaySound(self.properties.detectorsound)
			Wait(1)
			self.properties.greenLight.visible = false
			self.on = false
		end
	end)
end

return DectectorTrigger
