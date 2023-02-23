local PlayerAbilitiesScript = {}

PlayerAbilitiesScript.Properties = {
	{ name = "range", type = "number", default = 100 },
	{ name = "strength", type = "number", default = 100 },
	{ name = "pushCooldown", type = "number", default = 10 },
	{ name = "pullCooldown", type = "number", default = 10 },
	{ name = "boostCooldown", type = "number", default = 30 },
	{ name = "pushSound", type = "entity" },
	{ name = "pullSound", type = "entity" },
	{ name = "boostSound", type = "entity" },
	{ name = "pushEffect", type = "entity" },
	{ name = "pullEffect", type = "entity" },
	{ name = "boostEffect", type = "entity" },
	{ name = "boostStrength", type = "number", default = 100 },
	{ name = "pullButton", type = "text" },
	{ name = "pushButton", type = "text" },
	{ name = "boostButton", type = "text" },
	{ name = "onCooldownSound", type = "soundasset" },
	{ name = "onCooldownMsg", type = "text" }
}

function PlayerAbilitiesScript:Init()
	self.pushEnabled = true
	self.pullEnabled = true
	self.boostEnabled = true
end

function PlayerAbilitiesScript:LocalInit()
	self:GetEntity().playerAbilitiesWidget.js.data.pullButton = self.properties.pullButton
	self:GetEntity().playerAbilitiesWidget.js.data.pushButton = self.properties.pushButton
	self:GetEntity().playerAbilitiesWidget.js.data.boostButton = self.properties.boostButton
end

function PlayerAbilitiesScript:OnButtonPressed(btn)
	if btn == "primary" and self.pushEnabled then
		self:SendPush()
	elseif btn == "secondary" and self.pullEnabled then
		self:SendPull()
	elseif btn == "jump" and self.boostEnabled then
		self:SendBoost()
	elseif btn == "primary" or btn == "secondary" or btn == "jump" then
		self:GetEntity():GetUser():SendToScripts("PlaySoundLocally",self.properties.onCooldownSound)
		self:GetEntity():GetUser():SendToScripts("AddNotification", self.properties.onCooldownMsg, { ability = self:MapButtonToAbility(btn) })
	end
end

function PlayerAbilitiesScript:MapButtonToAbility(btn)
	if btn == "primary" then
		return "Push"
	elseif btn == "secondary" then
		return "Pull"
	elseif btn == "jump" then
		return "Boost"
	end
end

function PlayerAbilitiesScript:SendBoost()
	print("Sending push")
	self:LaunchSelf()
	self:TriggerCooldown("boost")
end

function PlayerAbilitiesScript:SendPush()
	print("Sending push")
	self:SendLaunch(1)
	self:TriggerCooldown("push")
end

function PlayerAbilitiesScript:SendPull()
	print("Sending pull")
	self:SendLaunch(-1)
	self:TriggerCooldown("pull")
end

function PlayerAbilitiesScript:TriggerCooldown(which, callback)
	self[which .. "Enabled"] = false
	self:LocalUpdateData(which, true)
	self.properties[which .. "Sound"].active = true
	self.properties[which .. "Effect"].active = true
	self:Schedule(function()
		Wait(self.properties[which .. "Cooldown"])
		self:LocalUpdateData(which, false)
		self[which .. "Enabled"] = true
		self.properties[which .. "Sound"].active = false
		self.properties[which .. "Effect"].active = false
	end)
end

function PlayerAbilitiesScript:LocalUpdateData(key, value)
	if IsServer() then 
		self:SendToLocal("LocalUpdateData", key, value)
		return
	end
	
	self:GetEntity().playerAbilitiesWidget:CallFunction("triggerCooldown", key, value, self.properties[key .. "Cooldown"])
	
	self:GetEntity().playerAbilitiesWidget.js.data[key] = value
end

function PlayerAbilitiesScript:LaunchSelf()
	local forward = self:GetEntity():GetForward()
	local launch = forward * self.properties.boostStrength
	launch.z = 500

	self:GetEntity():Launch(launch)
end

function PlayerAbilitiesScript:TryLaunch(origin, thing, modifier)
	local distance = Vector.Distance(origin, thing:GetPosition())
	if distance < self.properties.range then
		local direction = (thing:GetPosition() - origin):Normalize() * modifier
		local launch = direction * self.properties.strength
		launch.z = 1000
		if thing:IsA(Character) then
			thing:Launch(launch)
		else
			local parent = thing:GetParent()
			
			if parent then
				parent.flyScript.properties.flying = true -- need this to stick the effect and lights to it
			end
			
			pickupSpawnerScript = thing:FindScript("pickupSpawnerScript", true)
			thing.physicsEnabled = true
			thing:AddImpulse(launch * 30)
		end
		
	end
end

function PlayerAbilitiesScript:SendLaunch(modifier)
	local origin = self:GetEntity():GetPosition()
	
	-- might be slow
	local pickupScripts = GetWorld():FindAllScripts("pickupSpawnerScript")
	for i=1,#pickupScripts do
		local entity = pickupScripts[i]:GetEntity():GetParent()
		if entity:IsValid() then
			self:TryLaunch(origin, entity, modifier)
		end
	end

	GetWorld():ForEachUser(function(user)
		local player = user:GetPlayer()
		
		if player and player:IsValid() and player ~= self:GetEntity() then
			self:TryLaunch(origin, player, modifier)
		end
	end)
end

return PlayerAbilitiesScript
