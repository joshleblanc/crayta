local NPCplayActionsScript = {}

-- Script properties are defined here
NPCplayActionsScript.Properties = {
	-- Example property
	{name = "waitTime", type = "number",default = 15},
	{name = "emoteChoice", type = "emoteasset",},
}

--This function is called on the server when this entity is created
function NPCplayActionsScript:Init()
	self:Schedule(function()
		while true do
			Wait(self.properties.waitTime)
			self:GetEntity():PlayEmote(self.properties.emoteChoice)
		end
	end)
	
end




return NPCplayActionsScript
