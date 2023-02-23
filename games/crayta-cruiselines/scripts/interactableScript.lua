local InteractableScript = {}

-- Script properties are defined here
InteractableScript.Properties = {
	-- Example property
	{name = "interactionSound", type = "soundasset"},
	{name = "cooldownSound", type = "soundasset"},
	
	{name = "cooldownTime", type = "number", default = 3},
	{name = "message", type = "text"},
}

--This function is called on the server when this entity is created
function InteractableScript:Init()
	self.onCooldown = false
end


function InteractableScript:OnInteract(player)
	if self.onCooldown == false then
		local sound
		self:Schedule(function()
			self.onCooldown = true
			if self.properties.interactionSound then
				sound = self:GetEntity():PlaySound(self.properties.interactionSound)
			end
			
			if self.properties.message ~= "" then
				player:GetUser():SendToScripts("Shout",self.properties.message)
			end
			Wait(self.properties.cooldownTime)
			self.onCooldown = false
			self:GetEntity():StopSound(sound,1)
		end)
	else
		if self.properties.cooldownSound then
			self:GetEntity():PlaySound(self.properties.cooldownSound)
		end
	end
	
end


return InteractableScript
