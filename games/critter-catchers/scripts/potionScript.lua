local PotionScript = {}

-- Script properties are defined here
PotionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "healAmt", type = "number", default = 50 },
	{ name = "healSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function PotionScript:Init()
end

function PotionScript:Heal(user) 
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "Heal", user)
		return
	end
	
	local player = user:GetPlayer()

	
	print("Running heal")
	
	player:SendToScripts("OpenMenuOption", "Monsters")
	user:SendToScripts("Prompt", "Which monster do you want to heal?", {}, function(result)
		print("Want to heal", result)
		
		if not result then 
			if player.battleScreenScript.usingItem then 
				player.battleScreenScript:CancelUseItem()
			end
			return
		end 
		
		local monsters = player:FindScript("playerMonstersControllerScript", true):GetParty()
		local monster = monsters[result]
		
		local hpBefore = monster.properties.hp
		local hpAfter
		if monster.properties.hp > 0 then 
			monster:Heal(self.properties.healAmt)
			hpAfter = monster.properties.hp
			player.cMenuMonstersScript:UpdateMonsters()
		else
			user:SendToScripts("AddNotification", "You cannot heal unconscious monsters")
			return
		end
				
		user.inventoryScript:SendToServer("RemoveTemplate", self:GetEntity():GetTemplate(), 1)
		
		user:SendToScripts("AddNotification", FormatString("{1} healed {2} hp", monster.properties.name, hpAfter - hpBefore))
		
		if player.battleScreenScript.inBattle and player.battleScreenScript.usingItem then 
			player:SendToScripts("CloseMenuOption", "Monsters")
			player.battleScreenScript:AfterUsedItem({
				FormatString("You used {1}", self:GetEntity():FindScriptProperty("friendlyName")),
				FormatString("{1} healed for {2}", monster.properties.name, self.properties.healAmt)
			})
			local sound = player:PlaySound2D(self.properties.healSound)
			sound:SetPitch(2)
		end
	end)
	
end

return PotionScript
