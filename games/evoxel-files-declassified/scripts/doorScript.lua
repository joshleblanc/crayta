local DoorScript = {}

-- Script properties are defined here
DoorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "openSound", type = "soundasset" },
	{ name = "closeSound", type = "soundasset" }
}

--This function is called on the server when this entity is created
function DoorScript:Init()
	self.open = 0
end

function DoorScript:OnTriggerEnter(entity)
	if not entity:IsA(Character) then return end
	
	self.open = self.open + 1
	if self.open > 0 then
		self:Open()
	end
end

function DoorScript:OnTriggerExit(entity)
	if not entity:IsA(Character) then return end
	
	self.open = self.open - 1
	if self.open == 0 then
		self:Close()
	end
end

function DoorScript:Open()
	self:GetEntity():PlayAnimation("Opening")
	self:GetEntity():PlaySound(self.properties.openSound)
end

function DoorScript:Close()
	self:GetEntity():PlayAnimation("Closing")
	self:GetEntity():PlaySound(self.properties.closeSound)
end

return DoorScript
