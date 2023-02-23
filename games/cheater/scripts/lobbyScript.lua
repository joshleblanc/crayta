local LobbyScript = {} 

LobbyScript.Properties = {
	{ name = "waitingForPlayersMsg", type = "text", },
	{ name = "playersInLobbyMsg", type = "text", },
	{ name = "gameStartsInMsg", type = "text", },

}

function LobbyScript:LocalInit()
	
	self.lobbyWidget = self:GetEntity().lobbyWidget
	self.lobbyWidget.js.lobby.waitingForPlayersMsg = self.properties.waitingForPlayersMsg
	self.lobbyWidget.js.lobby.playersInLobbyMsg = self.properties.playersInLobbyMsg
	self.lobbyWidget.js.lobby.gameStartsInMsg = self.properties.gameStartsInMsg
	self.lobbyWidget.visible = false
	
	self.game = GetWorld():FindScript("gameScript")
	
end

function LobbyScript:ShowLobby(params)
	
	if not self:GetEntity():IsLocal() then
		self:SendToLocal("ShowLobby", params)	
		return
	end
	
	self.lobbyWidget.visible = true
	self.lobbyWidget.js:CallFunction("ResetAnimations");

	self.startTime = params.startTime or 0
	self.totalTime = params.totalTime or 0
	self.morePlayers = params.morePlayers or false
	self:UpdateLobby()
	
	if self.lobbyTask == nil then
		self.lobbyTask = self:Schedule(
			function()
				while true do
					Wait(0.5)
					self:UpdateLobby()
				end
			end
		)
	end
end

function LobbyScript:HideLobby()

	if not self:GetEntity():IsLocal() then
		self:SendToLocal("HideLobby")	
		return
	end
	
	self.lobbyWidget.visible = false
	
	if self.lobbyTask then
		self:Cancel(self.lobbyTask)
		self.lobbyTask = nil
	end
end

function LobbyScript:UpdateLobby()

	local displayUsers = {}
	self.game:ForEachUser(
		function(user)
			table.insert(displayUsers, { name = user:GetUsername(), icon = user:GetPlayerCardIcon() })
		end
	)
	self.lobbyWidget.js.lobby.users = displayUsers

	self.lobbyWidget.js.lobby.morePlayers = self.morePlayers
	if not self.morePlayers then
		self.lobbyWidget.js.lobby.timeRemaining = math.ceil(math.max(self.startTime + self.totalTime - GetWorld():GetServerTime(), 0.0))
	end

end

return LobbyScript
