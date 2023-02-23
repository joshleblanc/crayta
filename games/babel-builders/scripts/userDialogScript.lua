local UserDialogScript = {}

-- Script properties are defined here
UserDialogScript.Properties = {
	-- Example property
	{ name = "dialogs", type = "text", container = "array" },
	{ name = "cameras", type = "entity", container = "array" },
	{ name = "continueButton", type = "text" },
	{ name = "forceIntro", type = "boolean", default = false },
	{ name = "playerTemplate", type = "template" },
	{ name = "team1Spawn", type = "entity" },
	{ name = "team2Spawn", type = "entity" }
}

--This function is called on the server when this entity is created
function UserDialogScript:Init()
	self.data = self:GetSaveData()
	if self.properties.forceIntro then
		self.data = {}
	end
	
	if not self.data.completed then
		self:PlayIntro()
	end
end

function UserDialogScript:PlayIntro()
	-- Skip the intro if no cameras are setup
	if #self.properties.cameras == 0 then
		return
	end

	-- player isn't available at this point, so wait for it
	-- to be, then lock the input
	self:Schedule(function()
		Wait()
		local player = self:GetEntity():GetPlayer()
		
		while not player do
			player = self:GetEntity():GetPlayer()
		end
		if not self.data.completed then
			player:SetInputLocked(true)
		end
	end)
	self:GetEntity().userQuestScript:Hide()
	self:GetEntity():SetCamera(self.properties.cameras[1])
	self:GetEntity():SendToLocal("LocalPlayIntro")
end

function UserDialogScript:LocalPlayIntro()
	if IsServer() then
		self:SendToLocal("PlayLocalIntro")
		return
	end
	
	self.widget:Show()
	self:Transition(1)
end

function UserDialogScript:SetCamera(index)
	self:GetEntity():SetCamera(self.properties.cameras[index], 1)
end

function UserDialogScript:Transition(index)
	if IsServer() then
		self:SendToLocal("Transition", index)
		return
	end
	
	self.currentIndex = index
	
	-- fade to black
	self.widget:CallFunction("setInstruction", self.properties.dialogs[index])
	
	self:SendToServer("SetCamera", index)
	-- fade in from black
end

function UserDialogScript:Complete()
	self:GetEntity():SendToScripts("Debug", "Sending to server")
	if not IsServer() then
		self:SendToServer("Complete")
		return
	end
	
	self:GetEntity():SendToScripts("Debug", "On Server " .. tostring(self.data.completed))
	
	if self.data.completed then return end 
	
	self:GetEntity():SendToScripts("Debug", "Sending to local complete")
	
	self:LocalComplete()
	
	self:GetEntity():SendToScripts("Debug", "Showing quest")
	local questScript = self:GetEntity().userQuestScript
	
	self:GetEntity():SendToScripts("Debug", "Quest Script: " .. tostring(questScript))
	if questScript and questScript:HasQuest() then
		questScript:Show()
	end
	
	self:GetEntity():SendToScripts("Debug", "Finishing")
	self.data.completed = true
	self:SetSaveData(self.data)
	self:GetEntity():SetCamera(self:GetEntity():GetPlayer(), 1)	
	self:GetEntity():GetPlayer():SetInputLocked(false)
end

function UserDialogScript:LocalComplete()
	if IsServer() then
		self:SendToLocal("LocalComplete")
		return
	end
	self:GetEntity():SendToScripts("Debug", "Doing to local complete")
	self.currentIndex = #self.properties.dialogs + 1
	self.widget:Hide()
end

function UserDialogScript:LocalInit()
	self.widget = self:GetEntity().userDialogWidget
	self.widget.js.data.continueButton = self.properties.continueButton
end

function UserDialogScript:LocalOnButtonPressed(btn)
	if not self.currentIndex then return end 
	
	if btn == "jump" then
		if self.currentIndex == #self.properties.dialogs then
			self:GetEntity():SendToScripts("Debug", "Complete")
			self:Complete()
		elseif self.currentIndex < #self.properties.dialogs then 
			self:Transition(self.currentIndex + 1)
		end
	end
end

return UserDialogScript
