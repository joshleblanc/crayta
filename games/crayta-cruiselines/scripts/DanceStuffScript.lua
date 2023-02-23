local DanceStuffScript = {}

-- Script properties are defined here
DanceStuffScript.Properties = {
	-- Example property
	{name = "lightLocator", type = "entity"},
	{name = "music", type = "entity"},
	{name = "camera", type = "entity" }
}

--This function is called on the server when this entity is created
function DanceStuffScript:Init()
	self.currentStatus = false
	self.event = nil
	
	self.playersInTrigger = {}
end

function DanceStuffScript:StartParticipation(player)
	if self.event then
		player.playerDanceEventScript:Start(function()
			print("Good to spin")
			print("rewarding participation")
			self.event:RewardParticipation(player)
			
			local transitionTime = 1.5
			player:GetUser():SetCamera(self.properties.camera, transitionTime)
			player.playerDanceEventScript:SendToLocal("SpinCamera", self.properties.camera:GetParent(), transitionTime)
		end)
	else
		table.insert(self.playersInTrigger, player)
	end
end

function DanceStuffScript:CancelParticipation(player)
	local indexToRemove
	for i, p in ipairs(self.playersInTrigger) do
		if p == player then
			indexToRemove = i
		end
	end
	
	if indexToRemove then
		table.remove(self.playersInTrigger, indexToRemove)
	end

	if self.event then
		player.playerDanceEventScript:CancelParticipation()
	end
end

function DanceStuffScript:StartDance()
	local lights = self.properties.lightLocator:GetChildren()
	for i=1, #lights do
		lights[i].visible = true
	end
	self.properties.music.active = true
end

function DanceStuffScript:EndDance()
	local lights = self.properties.lightLocator:GetChildren()
	for i=1, #lights do
		lights[i].visible = false
	end
	self.properties.music.active = false
end

function DanceStuffScript:ToggleDance(event)
	if self.currentStatus then
		self:StartDance()
	else
		self:EndDance()
	end
end

function DanceStuffScript:Activate(event)
	self.event = event
	
	self:Schedule(function()
		print("players in trigger", #self.playersInTrigger)
		for _, player in ipairs(self.playersInTrigger) do
			self:StartParticipation(player)
		end
	end)
	
	self.currentStatus = true
	self:GetEntity().mightyAnimationGroupScript:Play()
end

function DanceStuffScript:Deactivate(event)
	self.event = nil
	self.currentStatus = false
	self:GetEntity().mightyAnimationGroupScript:Play()
end

return DanceStuffScript
