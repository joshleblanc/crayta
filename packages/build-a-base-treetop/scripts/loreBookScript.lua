local LoreBookScript = {}

-- Script properties are defined here
LoreBookScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "interactPrompt", type = "text" },
	{ name = "id", type = "string" },
	{ name = "body", type = "text" },
	{ name = "header", type = "text" },
	{ name = "takeSound", type = "entity" },
	{ name = "daily", type = "boolean", default = true },
	{ name = "effect", type = "entity" },
	{ name = "sound", type = "entity" }
}

function LoreBookScript:ClientInit()
	self:Schedule(function()
		local user = GetWorld():GetLocalUser()
		local effect = self.properties.effect
		local sound = self.properties.sound
		
		-- Wait for local data to be initialized
		while not user.userLoreBookScript:IsReady() do 
			Wait()
		end 
		
		while true do
			print("checking can read", self.properties.id, user.userLoreBookScript:CanRead(self.properties.id))
			if user.userLoreBookScript:CanRead(self.properties.id) then
				effect.visible = true
				sound.active = true
			else
				effect.visible = false
				sound.active = false
			end
			Wait(60)
		end
	end)
end

function LoreBookScript:ClientHandleInteract(user)
	if GetWorld():GetLocalUser() ~= user then return end 
	
	self.properties.effect.visible = false
	self.properties.sound.active = false
end

function LoreBookScript:HandleInteract(player)
	local user = player:GetUser()
	self:Schedule(function()
		self.properties.takeSound.active = true
		user:SendToScripts("OpenLoreBook", self.properties.id, self.properties.header, self.properties.body, self.properties.daily)
		self:SendToAllClients("ClientHandleInteract", user)
		Wait(1)
		self.properties.takeSound.active = false
	end)
end

function LoreBookScript:GetInteractPrompt(prompts)
	prompts.interact = self.properties.interactPrompt
end

return LoreBookScript
