local DoorScript = {}

-- Script properties are defined here
DoorScript.Properties = {
	{ name = "openSound", type = "soundasset" },
	{ name = "closeSound", type = "soundasset" },
	{ name = "defaultState", type = "string", options = { "open", "closed" }, default = "open" },
}

--This function is called on the server when this entity is created
function DoorScript:Init()
	self.state = self.properties.defaultState
	
	if self.state == "open" then
		self:Open()
	else
		self:Close()
	end
end

function DoorScript:Toggle()
	if self.state == "open" then
		self:Close()
	else
		self:Open()
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
