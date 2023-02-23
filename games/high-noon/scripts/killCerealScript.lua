local KillCerealScript = {}

-- Script properties are defined here
KillCerealScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function KillCerealScript:OnButtonPressed(btn)
	local player = self:GetEntity()
	local user = player:GetUser()
	local name = user:GetUsername()
	if btn == "extra2" and tostring(name) == "Cereal" then
		--GetWorld():FindScript("HighNoonControllerScript"):SendToScript("DropAmmo", user)
		player:SendToScripts("Kill", player)
	end
end

return KillCerealScript
