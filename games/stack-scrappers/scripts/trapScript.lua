local TrapScript = {}

-- Script properties are defined here
TrapScript.Properties = {
	-- Example property
	{ name = "duration", type = "number", default = 10, tooltip = "Duration trap is active" },
	{ name = "trigger", type = "entity" },
	{ name = "onActivate", type = "event" },
	{ name = "onDeactivate", type = "event" },
	{ name = "lethal", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function TrapScript:Init()
	self.active = false
	self.properties.trigger.onTriggerEnter:Listen(self, "Activate")
end

function TrapScript:Activate(player)
	if not self.active then
		self:Schedule(function()
			self.properties.onActivate:Send()
			self.active = true
			Wait(self.properties.duration)
			self.properties.onDeactivate:Send()
			self.active = false
		end)
	end
	if self.properties.lethal then
		player:SendToScripts("Kill", self:GetEntity())
	end
	
end

return TrapScript
