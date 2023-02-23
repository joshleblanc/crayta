local LevelUpScript = {}

-- Script properties are defined here
LevelUpScript.Properties = {
	-- Example property

}

--This function is called on the server when this entity is created
function LevelUpScript:Init()
end

function LevelUpScript:OpenWidget(player)
	player:GetUser().userStatsScript:ShowWidget()
end

function LevelUpScript:GetInteractPrompt(prompts)
	prompts.interact = "Talk"
end

function LevelUpScript:OnTriggerEnter(player)
	if not player.GetUser then return end 
	
	if player:GetUser().objectiveScript:ObjectiveStatus({ "default" }) == 0 then 
		player:GetUser().levelUpPromptScript:DoDialogue(self)
	end
end

function LevelUpScript:OnTriggerExit(player)
	if not player.GetUser then return end 
	
	if player:GetUser().objectiveScript:ObjectiveStatus({ "default" }) == 0 then 
		player:GetUser().objectiveScript:ObjectiveCompleted("default")
	end
	
end
function LevelUpScript:Prompt(player)
	if player:GetUser().NPCDialogue:GetActive() then return end 
	
	if player:GetUser().objectiveScript:ObjectiveStatus({ "default" }) > 0 then 
		player:GetUser().levelUpPromptScript:Prompt(self)
	end
end

return LevelUpScript
