local TransportScript = {}

-- Script properties are defined here
TransportScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "dialog", type = "text" },
	{ name = "prompt", type = "text" },
	{ name = "doorSound", type = "soundasset" },
	{ name = "transportOnInteract", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function TransportScript:Init()
	self.locationController = GetWorld():FindScript("locationControllerScript")
end

function TransportScript:ClientInit()
	self.options = self:GetEntity():FindAllScripts("transportOptionScript")
	self:Init()
end

function TransportScript:OnInteract(player)
	if not self.properties.transportOnInteract then return end 
	
	self:HandleInteract(player)
end

function TransportScript:HandleInteract(player)
	if player:IsA(Character) then 
		player:GetUser():SendToScripts("DoOnLocal", self:GetEntity(), "LocalPresentOptions")
	end
end

function TransportScript:GoTo(option)
	local user = GetWorld():GetLocalUser()
	
	user.userLocationScript:GoTo(option.properties.template, option.properties.spawnLocation, self.properties.doorSound)
end

function TransportScript:GetInteractPrompt(prompts)
	if #self.options > 1 then 
		prompts.interact = "Go somewhere"
	else 
		prompts.interact = FormatString("Go to {1}", self.options[1].properties.name)
	end
end

function TransportScript:LocalPresentOptions()
	local user = GetWorld():GetLocalUser()
	
	local options = {}
	for index, option in ipairs(self.options) do 
		table.insert(options, { value = index, name = option.properties.name })
	end
	
	if #self.options > 1 then 
		user:SendToScripts("Prompt", self.properties.dialog, options, function(result)
			if result then 
				local selectedOption = self.options[result]
				self:GoTo(selectedOption)
			end
		end)
	elseif #self.options == 1 then
		self:GoTo(self.options[1])
	else
		--print("Transport script has no options")
	end
end

return TransportScript
