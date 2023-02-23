local FishShopGameScript = {}

-- Script properties are defined here
FishShopGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "camera", type = "entity" },
	{ name = "chopSound", type = "soundasset" },
	{ name = "knife", type = "entity" },
	{ name = "missSounds", type = "soundasset", container = "array" },
	{ name = "running", type = "boolean", default = false, editable = false },
	{ name = "winningSound", type = "soundasset"},
	{ name = "losingSound", type = "soundasset"},
	{ name = "shakeAsset", type = "camerashakeasset"},
}

--This function is called on the server when this entity is created
function FishShopGameScript:Init()
	self.playing = {}
end

function FishShopGameScript:StartEvent(event)
	self.properties.running = true
	self.event = event
end

function FishShopGameScript:StopEvent(event)
	self.properties.running = false
end

function FishShopGameScript:GetEvent()
	return self.event
end

function FishShopGameScript:HandleInteract(player)
	if not self.properties.running then return end
	if self:AlreadyPlaying(player) then return end 
	
	table.insert(self.playing, player)
	
	local user = player:GetUser()
	user:SetCamera(self.properties.camera)
	
	user:SendToScripts("DoOnLocal", self:GetEntity(), "LocalHandleInteract")
end

function FishShopGameScript:AlreadyPlaying(player)
	for _, v in ipairs(self.playing) do
		if v == player then
			return true
		end
	end
	return false
end

function FishShopGameScript:LocalHandleInteract()
	local user = GetWorld():GetLocalUser()
	
	local missed = 0
	user:SendToScripts("DoQuickTimeEvent", function()
		for i=1,10 do 
			local result = user.userQuickTimeScript:RandomButtonPressQTE(1.5)
			if result then
				self.properties.knife:PlaySound(self.properties.chopSound)
			else
				missed = missed + 1
				for i=1,#self.properties.missSounds do
					self.properties.knife:PlaySound(self.properties.missSounds[i])
					user:PlayCameraShakeEffect(self.properties.shakeAsset,.5)
				end
			end
			
			local rot = self.properties.knife:GetRelativeRotation()
			self.properties.knife:PlayRelativeTimeline(
				0, rot,
				0.1, rot * Rotation.New(90, 0, 0),
				0.5, rot
			)
		end
		
		if missed > 0 then
			user:SendToScripts("Shout", FormatString("You missed {1}! Try again!", missed))
			user:PlaySound(self.properties.losingSound)
		else
			self:SendToServer("Reward", user)
			user:PlaySound(self.properties.winningSound)
		end
	
		self:SendToServer("Finish", user)
	end)
end

function FishShopGameScript:Reward(user)
	if not self.event then return end 
	
	self.event:RewardParticipation(user:GetPlayer())
end

function FishShopGameScript:Finish(user)
	local player = user:GetPlayer()
	local index
	for i, v in ipairs(self.playing) do
		if v == player then
			index = i
		end 
	end
	
	if index then
		table.remove(self.playing, index)
	end
	
	user:SetCamera(user:GetPlayer())
end

function FishShopGameScript:GetInteractPrompt(prompts)
	if not self.properties.running then return end 
	
	prompts.interact = "Carve a pumpkin!"
end

return FishShopGameScript
