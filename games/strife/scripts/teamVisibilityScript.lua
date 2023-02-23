local TeamVisibilityScript = {}

-- Script properties are defined here
TeamVisibilityScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "owner", type = "number", default = 0 },
	{ name = "respawnDelay", type = "number", default = 30 }
}

--This function is called on the server when this entity is created
function TeamVisibilityScript:ClientInit()
	self:AdjustVisibility(self.properties.owner)
end

function TeamVisibilityScript:AdjustVisibility(owner)
	local user = GetWorld():GetLocalUser()
	local team = user:FindScriptProperty("team")
	if owner == team then 
		self:GetEntity():SendToScripts("ShowPickup")
	else
		self:GetEntity():SendToScripts("HidePickup")
	end
end

function TeamVisibilityScript:ShowForTeamAfterDelay()
	self:Schedule(function()
		Wait(self.properties.respawnDelay)
		self:SendToAllClients("AdjustVisibility", self.properties.owner)
	end)
end

function TeamVisibilityScript:HandleOwnerChange(id, owner)
	self.properties.owner = owner
	self:SendToAllClients("AdjustVisibility", owner)
end

return TeamVisibilityScript
