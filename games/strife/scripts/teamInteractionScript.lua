local TeamInteractionScript = {}

-- Script properties are defined here
TeamInteractionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "owner", type = "number", default = 0 },
	{ name = "msg", type = "text" }
}

function TeamInteractionScript:OnInteract(player)
	if player:FindScriptProperty("isGhost") then return end 
	
	local owner = self:GetEntity():FindScriptProperty("owner")
	local team = player:GetUser():FindScriptProperty("team")
	
	print("interacting", owner, team)
	
	if owner == team then 
		self:GetEntity():SendToScripts("Pickup", player)
	else
		player:GetUser():SendToScripts("Shout", self.properties.msg)
	end
end

function TeamInteractionScript:HandleCapture(id, owner)
	self.properties.owner = owner
end

return TeamInteractionScript
