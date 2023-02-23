local InteractTriggerSoundEntity = {}

-- Script properties are defined here
InteractTriggerSoundEntity.Properties = {
	-- Example property
	{name = "soundEntity", type = "entity"},
	{name = "timeBetweenUses", type = "number", default = 10},
	{name = "regularSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function InteractTriggerSoundEntity:Init()
	self.played = false
end

function InteractTriggerSoundEntity:OnInteract(player)
	self:Schedule(function()
	if self.played == false then
		self.played = true
		if self.properties.soundEntity ~= nil then		
				self.properties.soundEntity.active = true
				Wait(self.properties.timeBetweenUses)
				self.properties.soundEntity.active = false
			end
		else
			self:GetEntity():PlaySound(self.properties.regularSound)
			Wait(self.properties.timeBetweenUses)
		end
		self.played = false
	end)
	
end

return InteractTriggerSoundEntity
