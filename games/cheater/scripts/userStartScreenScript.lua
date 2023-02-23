local UserStartScreenScript = {}

-- Script properties are defined here
UserStartScreenScript.Properties = {
	-- Example property
	{name = "startingBellSound", type = "soundasset"},
	{name = "ambienceSound", type = "soundasset"},
	{name = "startCamera", type = "entity"},
	{name = "startGameCamera", type = "entity"},
	{name = "leaderboardCamera", type = "entity"},
	{name = "instructionCamera", type = "entity"},
	{name = "startGameDoor", type = "entity"},
	{name = "selectionSound", type = "soundasset"},
	{name = "selectedSound", type = "soundasset"},
	{name = "musicSound", type = "soundasset"},
	{name = "effectThing", type = "effectasset"},
	{name = "startGameSound", type = "soundasset"},
	{name = "leaderboardEntity", type = "entity" },
}

--This function is called on the server when this entity is created
function UserStartScreenScript:Init()
	print("WE HAVE INITIALIZED")
	self:ShowMenu()
end

function UserStartScreenScript:LocalInit()
	print("WE HAVE INITIALIZED LOCALLY")
	self.initialLeaderboardsPosition = self.properties.leaderboardEntity:GetPosition()
	self.shownLeaderboardsPosition = self.initialLeaderboardsPosition + Vector.New(0, 0, 325)
end

function UserStartScreenScript:ShowMenu()
	self:GetEntity():SetCamera(self.properties.startCamera)
	self.currentView = nil
	
	self:SendToLocal("LocalShowMenu")
end

function UserStartScreenScript:LocalShowMenu()
	self.widget = self:GetEntity().userStartScreenWidget
	self.widget:Show()

	
	self:Schedule(function()
		Wait(2.5)
		local bell = self:GetEntity():PlaySound2D(self.properties.startingBellSound, 1, "bell")
		
		self.ambience = self:GetEntity():PlaySound2D(self.properties.ambienceSound, 1, "ambience")
		
		self.ambience:SetVolume(.5)
		Wait(5)
		self:GetEntity():StopSound(bell,1)
		Wait(.5)
		self.music = self:GetEntity():PlaySound2D(self.properties.musicSound, 0, "music")
	end)
end


function UserStartScreenScript:StopStartMenuSound()
	self:GetEntity():StopSound(self.ambience,.4)
	self:GetEntity():StopSound(self.properties.musicSound,1)
	self.music:SetVolume(.5)
end

function UserStartScreenScript:StartGame()
	if IsClient() then
		self:LocalReset()
		self:SelectedSound()
		self.widget.visible = false
		self.properties.startGameDoor:SendToScripts("OpenClassDoor")
		self:SendToServer("StartGame")
		local sound = self:GetEntity():PlaySound2D(self.properties.startGameSound)
		sound:SetVolume(.3)
		
	end
		
	if IsServer() then
		self:Schedule(function()
			if self:GetEntity():GetCamera() ~= self.properties.startCamera then
				self:GetEntity():SetCamera(self.properties.startCamera,1)
				Wait(1.2)
			end
			print("STARTING GAME")
			self:GetEntity():SetCamera(self.properties.startGameCamera,2.5)	
			Wait(2.5)
			self:GetEntity():SendToScripts("JoinGame")
		end)
	end
end


function UserStartScreenScript:StartLeaderboardView()
	if IsServer() then 
		self:Schedule(function()
			if self:GetEntity():GetCamera() ~= self.properties.startCamera then
				self:GetEntity():SetCamera(self.properties.startCamera,1)
				Wait(1.2)
			end
			print("STARTING VIEW")
			self:GetEntity():SetCamera(self.properties.leaderboardCamera,2)
			
		end)
	else 
		self:LocalReset()
		if self.currentView == "leaderboard" then 
			self:SendToServer("Reset")
			self.currentView = nil
		else
			self:SelectedSound()
			self:SendToServer("StartLeaderboardView")
			self.currentView = "leaderboard"
			self.properties.leaderboardEntity:PlayTimeline(
				0, self.initialLeaderboardsPosition, "EaseInOut",
				1.25, self.shownLeaderboardsPosition, "EaseInOut"
			)
		end
	end
end

function UserStartScreenScript:Reset()
	self:GetEntity():SetCamera(self.properties.startCamera,1)
end

function UserStartScreenScript:LocalReset()
	self.properties.leaderboardEntity:PlayTimeline(
		0, self.properties.leaderboardEntity:GetPosition(), "EaseInOut",
		1.25, self.initialLeaderboardsPosition, "EaseInOut"
	)
end

function UserStartScreenScript:StartInstructionCamera()
	if IsServer() then 
		self:Schedule(function()
			if self:GetEntity():GetCamera() ~= self.properties.startCamera then
				self:GetEntity():SetCamera(self.properties.startCamera,1)
				Wait(1.2)
			end
			self:GetEntity():SetCamera(self.properties.instructionCamera,2)
		end)
	else
		self:LocalReset()
		if self.currentView == "instructions" then 
			self:SendToServer("Reset")
			self.currentView = nil
		else
			self:SelectedSound()
			self:SendToServer("StartInstructionCamera")
			self.currentView = "instructions"
		end
	end
end

function UserStartScreenScript:SelectionSound()	
	self:GetEntity():PlaySound2D(self.properties.selectionSound)
end

function UserStartScreenScript:SelectedSound()	
	self:GetEntity():PlaySound2D(self.properties.selectedSound)
end

function UserStartScreenScript:OnUserLogin()
	
end

function UserStartScreenScript:ClientOnTick()
	
end



return UserStartScreenScript
