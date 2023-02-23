local TrainerBattleScript = {}

-- Script properties are defined here
TrainerBattleScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "dialogControl", type = "entity" },
	{ name = "questId", type = "string" },
	{ name = "reward", type = "number" },
}

--This function is called on the server when this entity is created
function TrainerBattleScript:ClientInit()
	self.monsters = self:GetEntity():FindAllScripts("monsterScript")
end

function TrainerBattleScript:HandleTriggerEnter(player)
	local user = player:GetUser()
	
	if not user.userQuestsScript:IsQuestComplete(self.properties.questId) then 
		self.properties.dialogControl:SendToScripts("StartDialog", player)
	end
end

function TrainerBattleScript:StartBattle(user)
	user:SendToScripts("EndDialog")
	
	if user.userQuestsScript:IsQuestComplete(self.properties.questId) then 
		return
	end

	local player = user:GetPlayer()
	
	local data = {}
	
	for _, mon in ipairs(self.monsters) do 
		table.insert(data, {
			entity = mon:GetEntity(),
			level = mon:GetLevel()
		})
	end
	
	player.battleScreenScript:StartBattle({
		monsters = data,
		name = self.properties.dialogControl:FindScriptProperty("name"),
		wildEncounter = false,
		questId = self.properties.questId,
		reward = self.properties.reward,
		dialog = self.properties.dialogControl
	})
end

return TrainerBattleScript
