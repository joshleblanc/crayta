local UserTeamScript = {}

-- Script properties are defined here
UserTeamScript.Properties = {
	-- Example property
	{ name = "team", type = "number" },
	{ name = "gameStorageController", type = "entity" }
}

--This function is called on the server when this entity is created
function UserTeamScript:Init()
	local data = self:GetSaveData()
	if data.team then
		if data.team == 0 then 
			data.team = 1
			self:SetSaveData({ team = 1 })
		end
		self.properties.team = data.team
		self:UpdateTeamWidget(self.properties.team)
	else
		GameStorage.GetCounter("total-players", function(value)
			self:GetEntity():SendToScripts("Debug", "Total players: " .. tostring(value))
			self.properties.team = (value % 2) + 1
			self:GetEntity():SendToScripts("Debug", "Calculated team: " .. tostring(self.properties.team))
			self:UpdateTeamWidget(self.properties.team)
			
			local totalPlayersOnTeamId = FormatString("team-{1}-players", self.properties.team)
			
			self.properties.gameStorageController:SendToScripts("Update", totalPlayersOnTeamId, 1)
			
			self:SetSaveData({ team = self.properties.team })
			self.properties.gameStorageController:SendToScripts("Update", "total-players", 1)
		end)
	end
end

function UserTeamScript:LocalInit()
	self.widget = self:GetEntity().userTeamWidget
end

function UserTeamScript:UpdateTeamWidget(team)
	if IsServer() then
		self:SendToLocal("UpdateTeamWidget", team)
		return
	end
	
	if team == 1 then
		self.widget.js.data.team = "East Craytasia"
	else
		self.widget.js.data.team = "West Craytasia"
	end
end

return UserTeamScript
