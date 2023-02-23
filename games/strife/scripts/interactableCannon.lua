local InteractableCannon = {}

-- Script properties are defined here
InteractableCannon.Properties = {
	-- Example property
	{name = "cannonShotSound", type = "soundasset",},
	{name = "cannonShotEffect1", type = "entity",},
	{name = "cannonShotEffect2", type = "entity",},
	
	{name = "fuseSound", type = "soundasset",},
	{name = "fire", type = "entity",},
	{name = "embers", type = "entity",},
	{name = "firelight", type = "entity",},
}

--This function is called on the server when this entity is created
function InteractableCannon:Init()
	self.shotRecently = false
end

function InteractableCannon:OnInteract()
	print("interacted")
	self:Schedule(function()
		if self.shotRecently ~= true then
			self.shotRecently = true
			local fuse = self:GetEntity():PlaySound(self.properties.fuseSound)
			self.properties.fire.active = true
			self.properties.embers.active = true
			self.properties.firelight.visible = true
			Wait(3)
			self:GetEntity():StopSound(fuse,1)
			Wait(.5)
			self.properties.embers.active = false
			self.properties.firelight.visible = false
			self.properties.fire.active = false
		
			self:GetEntity():PlaySound(self.properties.cannonShotSound)
			self.properties.cannonShotEffect1.active = true
			self.properties.cannonShotEffect2.active = true

			Wait(3)
			self.properties.cannonShotEffect1.active = false
			self.properties.cannonShotEffect2.active = false

			self.shotRecently = false
		end
	end)
end

return InteractableCannon