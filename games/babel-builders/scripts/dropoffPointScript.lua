local DropoffPointScript = {}

-- Script properties are defined here
DropoffPointScript.Properties = {
	-- Example property
	{ name = "dropoffTrigger", type = "entity" },
	{ name = "resource", type = "string", options = { "wood", "stone" } },
	{ name = "team", type = "number" },
	{ name = "stack", type = "template" },
	{ name = "stackOffset", type = "vector" },
	{ name = "capacity", type = "number", default = 10000 }
}

--This function is called on the server when this entity is created
function DropoffPointScript:Init()
	self.properties.dropoffTrigger.onInteract:Listen(self, "HandleTriggerEnter")
	
	self.stack = GetWorld():Spawn(self.properties.stack, Vector.Zero, Rotation.Zero)
	self.stack:AttachTo(self:GetEntity())
	self.stack:SetRelativePosition(self.properties.stackOffset)
	
	self.numLayers = self.stack.resourceStackScript:NumLayers()
	self.breakpoint = self.properties.capacity / self.numLayers
	
	self.key = FormatString("{1}-{2}", self.properties.team, self.properties.resource)
end

function DropoffPointScript:HandleStorageUpdate(key, value)
	if key == self.key then
		print("Dropping to update dropoff", key, value)
		local layer = math.ceil(value / self.breakpoint)
		self.stack.resourceStackScript:Show(layer)
	end
end

function DropoffPointScript:HandleTriggerEnter(player)
	if player:GetUser():FindScriptProperty("team") ~= self.properties.team then 
		player:GetUser():SendToScripts("Shout", "This isn't your kingdom!")
		return 
	end 
	
	player:SendToScripts("DropoffResource", self.properties.resource)
end

return DropoffPointScript
