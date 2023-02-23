local UserRespawnScript = {}

-- Script properties are defined here
UserRespawnScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "spawnLocation", type = "entity" },
	{ name = "playerTemplate", type = "template" },
	{ name = "enabled", type = "boolean", editable = false, default = true }
}

--This function is called on the server when this entity is created
function UserRespawnScript:Init()
	self.entity = self:GetEntity()
end

function UserRespawnScript:Enable()
	if not IsServer() then
		self:SendToServer("Enable")
		return
	end
	
	self.entity.promptsScript.properties.nextInstruction = Text.Format("Respawn")
	self.properties.enabled = true
end

function UserRespawnScript:Disable()
	if not IsServer() then
		self:SendToServer("Disable")
		return
	end
	
	self.entity.promptsScript.properties.nextInstruction = Text.Format("")
	
	self.properties.enabled = false
end

function UserRespawnScript:OnButtonPressed(btn)
	if not self.properties.enabled then return end 
	
	if btn == "next" then
		self:GetEntity():SpawnPlayerWithEffect(self.properties.playerTemplate, self.properties.spawnLocation)
	end
end

return UserRespawnScript
