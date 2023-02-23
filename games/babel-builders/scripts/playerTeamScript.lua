local PlayerTeamScript = {}

-- Script properties are defined here
PlayerTeamScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "team1Spawn", type = "entity" },
	{ name = "team2Spawn", type = "entity" }
}

--This function is called on the server when this entity is created
function PlayerTeamScript:Init()
	local team = self:GetEntity():GetUser():FindScriptProperty("team")
	
	self:Schedule(function()
		while team < 1 do
			Wait()
			team = self:GetEntity():GetUser():FindScriptProperty("team")
			print("test")
		end
		self:GetEntity():GetUser():SendToScripts("Debug", "Found team " .. tostring(team))
		self:GetEntity():SetPosition(self.properties["team" .. team .. "Spawn"]:GetPosition())	
	end)
end

return PlayerTeamScript
