local UserCheaterScript = {}

-- Script properties are defined here
UserCheaterScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "inGame", type = "boolean", default = false },
	{ name = "numObjectives", type = "number", default = 5 },
	{ name = "completionSpeed", type = "number", default = 5 },
	{ name = "completionSound", type = "soundasset" },
	{ name = "completionEffect", type = "effectasset" },
	
}

--This function is called on the server when this entity is created
function UserCheaterScript:Init()
	self.cheaterGameScript = GetWorld():FindScript("cheaterGameScript")
	self.desks = GetWorld():FindAllScripts("deskScript")
	self.game = GetWorld():FindScript("gameScript")
	
	self.objectiveProgress = 0
	
	self.widget = self:GetEntity().userCheaterWidget
	self.textWidget = self:GetEntity().screenTextWidget
	self.widget:Hide()
end

function UserCheaterScript:OnButtonPressed(btn)
	if btn == "extra2" and self.properties.inGame then 
		self:LeaveGame()
	end
end

function UserCheaterScript:HandleDeath()
	self:SetObjectives({})
end

function UserCheaterScript:Reset()
	for _, objective in ipairs(self.objects) do 
		self:SendToLocal("LocalHideObjective", objective)
	end
	self.objectives = {}
	self.objectiveIndex = 1
	self.objectiveProgress = 0
end

function UserCheaterScript:StartProgressingObjective(desk)
	if desk ~= self:CurrentObjective() then 
		return
	end
	
	self.progressObjectiveSchedule = self:Schedule(function()
		local player = self:GetEntity():GetPlayer()
		while player and player:IsAlive() do 
			local dt = Wait()
			self.objectiveProgress = self.objectiveProgress + (dt * self.properties.completionSpeed)
			self.widget.properties.progress = FormatString("{1}%", math.floor(self.objectiveProgress))
			--print(self.objectiveProgress)
			
			if math.floor(self.objectiveProgress) % 10 == 0 then 
				self:GetEntity():SendXPEvent("cheat")
			end
			
			if self.objectiveProgress >= 100 then 
				self:NextObjective()
				self:GetEntity():PlaySound(self.properties.completionSound)
				self:GetEntity():GetPlayer():PlayEffect(self.properties.completionEffect, true)
			end
		end
		
	end)
	
end

function UserCheaterScript:StopProgressingObjective(desk)
	if desk ~= self:CurrentObjective() then 
		return
	end
	
	if self.progressObjectiveSchedule then 
		print("Stopping")
		self:Cancel(self.progressObjectiveSchedule)
	end
end

function UserCheaterScript:NextObjective()
	self:GetEntity().scoreScript:AddScore(1)
	self:SendToLocal("LocalHideObjective", self:CurrentObjective())
	self.objectiveIndex = self.objectiveIndex + 1
	self.objectiveProgress = 0
	
	self.widget.properties.questionNumber = self.objectiveIndex
	self.widget.properties.progress = "0%"
	
	self:Cancel(self.progressObjectiveSchedule)
	
	if self.objectiveIndex > #self.objectives then 
		self:EndGame()
	else 
		self:SendToLocal("LocalShowObjective", self:CurrentObjective())
	end
	

end

function UserCheaterScript:EndGame()
	self.game:EndPlay()
end

function UserCheaterScript:JoinGame()
	if not IsServer() then 
		self:SendToServer("JoinGame")
		return
	end
	self.properties.inGame = true
	
	self.game:HandleUserJoin(self:GetEntity())
	self.objectiveIndex = 1
	self.objectiveProgress = 0
	self.widget.properties.progress = "0%"
	self.widget.properties.questionNumber = 1
	self.widget.visible = true
	self.textWidget.visible = true
	self:GetEntity():SetCamera(self.cheaterGameScript.properties.camera)
	
	
end

function UserCheaterScript:LeaveGame()
	if not IsServer() then 
		self:SendToServer("LeaveGame")
		return
	end
	
	self.properties.inGame = false
	
	local player = self:GetEntity():GetPlayer()
	if player then 
		player:Destroy()
	end
	self.game:HandleUserLeave(self:GetEntity())
	self.widget.visible = false
	self.textWidget.visible = false
	self:GetEntity().userStartScreenScript:ShowMenu()
	self:GetEntity().hudScript:HideHud()
	self:GetEntity().resultsScript:HideResults()
end

function UserCheaterScript:SetObjectives(objectives)
	if self.objectives then 
		for _, objective in ipairs(self.objectives) do 
			self:SendToLocal("LocalHideObjective", objective)
		end
	end
	
	self.objectives = objectives 
	self.objectiveIndex = 1
	self.objectiveProgress = 0
	self.widget.properties.progress = "0%"
	self.widget.properties.questionNumber = 1
end

function UserCheaterScript:CurrentObjective()
	return self.objectives[self.objectiveIndex]
end

function UserCheaterScript:ShowCurrentObjective()
	if IsServer() then 
		self:SendToLocal("LocalShowObjective", self:CurrentObjective())
		return
	end
end

function UserCheaterScript:LocalHideObjective(objective)
	objective:Deactivate()
end

function UserCheaterScript:LocalShowObjective(objective)
	objective:Activate()
end


return UserCheaterScript