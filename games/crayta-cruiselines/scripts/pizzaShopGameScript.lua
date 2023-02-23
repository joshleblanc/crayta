local PizzaShopGameScript = {}

-- Script properties are defined here
PizzaShopGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "camera", type = "entity" },
	{ name = "ovenCamera", type = "entity" },
	{ name = "oven", type = "entity" },
	{ name = "rawPizza", type = "entity" },
	{ name = "cookedPizza", type = "entity" },
	{ name = "dirtEffect", type = "effectasset" },
	{ name = "dirtEffectLocator", type = "entity" },
	{ name = "burntPizza", type = "entity" },
	{ name = "running", type = "boolean", default = false, editable = false },
	{ name = "fireEffect", type = "entity" },
	{ name = "doneSound", type = "soundasset" },
	{ name = "missVibration", type = "vibrationeffectasset" },
	{ name = "shakeAsset", type = "camerashakeasset"},
}

--This function is called on the server when this entity is created
function PizzaShopGameScript:Init()
	self.playing = {}
end

function PizzaShopGameScript:HandleInteract(player)
	if not self.properties.running then return end 
	if self:AlreadyPlaying(player) then return end 
	
	table.insert(self.playing, player)
	
	local user = player:GetUser()
	user:SetCamera(self.properties.camera)
	
	user:SendToScripts("DoOnLocal", self:GetEntity(), "LocalHandleInteract")
end

function PizzaShopGameScript:AlreadyPlaying(player)
	for _, v in ipairs(self.playing) do
		if v == player then
			return true
		end
	end
	return false
end

function PizzaShopGameScript:LocalHandleInteract(player)
	local user = GetWorld():GetLocalUser()
	
	local pizzaShowPosition = self.properties.rawPizza:GetPosition()
	local pizzaCookPosition = self.properties.cookedPizza:GetPosition()
	
	self.properties.cookedPizza.visible = false
	self.properties.burntPizza.visible = false
	self.properties.rawPizza.visible = true
	
	local missed = 0
	
	local innerDone = false
	
	self:Schedule(function()
		local modes = { "vertical", "horizontal", "vertical" }
		for i=1,3 do 
			local result, pos, accuracy = user.userMinigameScript:StartSync(75, modes[i])

			--local result = user.userQuickTimeScript:RandomButtonPressQTE(1)
			if result then
				self.properties.dirtEffectLocator:PlayEffect(self.properties.dirtEffect)	
				-- self.properties.knife:PlaySound(self.properties.chopSound)
			else
				user:PlayVibrationEffect(self.properties.missVibration)
				user:PlayCameraShakeEffect(self.properties.shakeAsset,.5)
				missed = missed + 1
				--[[
				for i=1,#self.properties.missSounds do
					self.properties.knife:PlaySound(self.properties.missSounds[i])
				end
				--]]
			end
		end
		
		self:ChangeCamera(user, self.properties.ovenCamera, 1)
			
		Wait(1)
		
		self.properties.oven:PlayAnimation("Opening")
		
		Wait(self.properties.rawPizza:PlayRelativeTimeline(
			0, self.properties.rawPizza:GetRelativePosition(), "EaseInOut",
			1, self.properties.rawPizza:GetRelativePosition() - Vector.New(0, 250, 0), "EaseInOut"
		))
		
		self.properties.oven:PlayAnimation("Closing")
	
		local result
		user:SendToScripts("DoQuickTimeEvent", function()			
			self.properties.fireEffect.active = true
			result = user.userQuickTimeScript:RandomButtonPressQTE(5)
			innerDone = true
		end)
		user:GetPlayer():SetInputLocked(true)
		
		while not innerDone do
			Wait()
		end
		
		self.properties.fireEffect.active = false
		self.properties.oven:PlayAnimation("Opening")
		
		if result then
			self.properties.cookedPizza.visible = true
			self.properties.rawPizza.visible = false
			self.properties.burntPizza.visible = false
			
			Wait(self.properties.cookedPizza:PlayRelativeTimeline(
				0, self.properties.cookedPizza:GetRelativePosition(), "EaseInOut",
				1, self.properties.cookedPizza:GetRelativePosition() + Vector.New(0, 250, 0), "EaseInOut"
			))
		else
			missed = missed + 1
			self.properties.cookedPizza.visible = false
			self.properties.rawPizza.visible = false
			self.properties.burntPizza.visible = true
			
			user:PlayCameraShakeEffect(self.properties.shakeAsset,.5)
			user:PlayVibrationEffect(self.properties.missVibration)
			
			Wait(self.properties.burntPizza:PlayRelativeTimeline(
				0, self.properties.burntPizza:GetRelativePosition(), "EaseInOut",
				1, self.properties.burntPizza:GetRelativePosition() + Vector.New(0, 250, 0), "EaseInOut"
			))
		end
		
		self.properties.oven:PlaySound(self.properties.doneSound)
		self.properties.oven:PlayAnimation("Closing")
		
		if missed > 0 then
			user:SendToScripts("Shout", FormatString("That's not quite right! Try again!"))
		else
			self:SendToServer("Reward", user)
		end
	
		Wait(1)
		user:GetPlayer():SetInputLocked(false)
		self:SendToServer("Finish", user)		

		self.properties.burntPizza:SetPosition(pizzaCookPosition)
		self.properties.cookedPizza:SetPosition(pizzaCookPosition)
		self.properties.rawPizza:SetPosition(pizzaShowPosition)
	end)
end

function PizzaShopGameScript:ChangeCamera(user, camera, time)
	if not IsServer() then
		self:SendToServer("ChangeCamera", user, camera, time)
		return
	end
	
	user:SetCamera(camera, time)
end

function PizzaShopGameScript:Reward(user)
	if not self.event then return end 
	
	self.event:RewardParticipation(user:GetPlayer())
end

function PizzaShopGameScript:Finish(user)
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

function PizzaShopGameScript:GetInteractPrompt(prompts)
	if not self.properties.running then return end 
	
	prompts.interact = "Make some pizza!"
end

function PizzaShopGameScript:StartEvent(event)
	self.properties.running = true
	self.event = event
end

function PizzaShopGameScript:StopEvent(event)
	self.properties.running = false
end

function PizzaShopGameScript:GetEvent()
	return self.event
end

return PizzaShopGameScript
