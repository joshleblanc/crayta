local LevelUpPromptScript = {}

-- Script properties are defined here
LevelUpPromptScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function LevelUpPromptScript:Init()
end

function LevelUpPromptScript:DoDialogue(script)
	if not IsServer() then 
		self:GetEntity().NPCDialogue.canInteract = false
		self:SendToServer("DoDialogue", script)
		return
	end
	
	script:GetEntity():GetParent():SendToScripts("DoDialogue", self:GetEntity():GetPlayer())
end

function LevelUpPromptScript:DoLevelUp(script)
	if not IsServer() then 
		self:SendToServer("DoLevelUp", script)
		return
	end
	script:GetEntity():SendToScripts("OpenWidget", self:GetEntity():GetPlayer())
end

function LevelUpPromptScript:Prompt(script)
	
	if IsServer() then 
		self:SendToLocal("Prompt", script)
		return
	end
	
	local options = {
		{ name = "Talk", value = "talk" },
		{ name = "Level Up", value = "level-up" },
	}
	
	local text = FormatString("Welcome, {1}", self:GetEntity():GetUsername())
	self:GetEntity():SendToScripts("Prompt", text, options, function(response)
		if response == "talk" then 
			self:DoDialogue(script)
		else 
			self:DoLevelUp(script)
		end 
	end)
end
return LevelUpPromptScript
