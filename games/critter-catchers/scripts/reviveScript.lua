local ReviveScript = {}

-- Script properties are defined here
ReviveScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "healSound", type = "soundasset" },
}

--This function is called on the server when this entity is created
function ReviveScript:Init()
end

function ReviveScript:Revive(user) 
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "Revive", user)
		return
	end
	
	local player = user:GetPlayer()
	
	print("Running revive")
	
	player:SendToScripts("OpenMenuOption", "Monsters")
	user:SendToScripts("Prompt", "Which monster do you want to heal?", {}, function(result)
		if not result then 
			if player.battleScreenScript.usingItem then 
				player.battleScreenScript:CancelUseItem()
			end
			return
		end 
		
		local monsters = player:FindScript("playerMonstersControllerScript", true):GetParty()
		local monster = monsters[result]
		
		if monster.properties.hp > 0 then 
			user:SendToScripts("AddNotification", "You cannot revive healthy monsters")
			return
		else
			monster:Heal(math.floor(monster:GetMaxHp() / 2))
			player.cMenuMonstersScript:UpdateMonsters()
		end
				
		user.inventoryScript:SendToServer("RemoveTemplate", self:GetEntity():GetTemplate(), 1)
		
		user:SendToScripts("AddNotification", FormatString("{1} revived", monster.properties.name))
		
		if player.battleScreenScript.usingItem then 
			player:SendToScripts("CloseMenuOption", "Monsters")
			player.battleScreenScript:AfterUsedItem({
				FormatString("You used {1}", self:GetEntity():FindScriptProperty("friendlyName")),
				FormatString("{1} healed for {2}", monster.properties.name, self.properties.healAmt)
			})
		end
	end)
	local sound = player:PlaySound2D(self.properties.healSound)
	sound:SetPitch(2)
	
end

return ReviveScript
