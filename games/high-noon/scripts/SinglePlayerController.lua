local SinglePlayerController = {}

-- Script properties are defined here
SinglePlayerController.Properties = {
	-- Example property
	{name = "HighNoonController", type = "entity",},
}

--This function is called on the server when this entity is created
function SinglePlayerController:Init()
self.soloModeActive = false
self:Schedule(
	function()
		while true do
			Wait(5)
			local userTable = self:CheckPlayerCounts()
				if #userTable == 1 and self.soloModeActive == false then
					self.soloUser = userTable[1]
					self:StartSoloMode()
				elseif #userTable > 1 then
					self:StopSoloMode()				
				end
		end
	end)
end

function SinglePlayerController:StartSoloMode()
	self.soloUser.UserSinglePlayerScript:SinglePlayerMode(true)
	print("Starting Solo Mode")
	self.properties.HighNoonController.HighNoonControllerScript:PauseMultiplayer()
	self.soloModeActive = true
end

function SinglePlayerController:StopSoloMode()
	self.soloUser.UserSinglePlayerScript:SinglePlayerMode(true)
	print("Stopping Solo Mode")
	self.soloModeActive = false
	--Start multiplayer
	self.soloUser.UserSinglePlayerScript:EndSinglePlayerGame()	
	self.properties.HighNoonController.HighNoonControllerScript:Run()
	self.soloUser = nil
end


function SinglePlayerController:CheckPlayerCounts()
	local userTable = GetWorld():GetUsers()
	return userTable
end


return SinglePlayerController
