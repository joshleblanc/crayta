local CMenuMonstersScript = {}

-- Script properties are defined here
CMenuMonstersScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function CMenuMonstersScript:LocalInit()
	self.menuOption = self:GetEntity().cMenuScript:FindOption("Monsters")

	
	self.monstersController = self:GetEntity():FindScript("playerMonstersControllerScript", true)
	self.widget = self:GetEntity().cMenuMonstersWidget

	self.menuOption.properties.onOpen:Listen(self, "HandleWidgetOpen")
	self.menuOption.properties.onClose:Listen(self, "HandleWidgetClose")
end

function CMenuMonstersScript:HandleWidgetOpen()
	self:UpdateMonsters()
end

function CMenuMonstersScript:HandleWidgetClose()
	if IsServer() then 
		self:SendToLocal("HandleWidgetClose")
		return
	end
	
	self:GetEntity():GetUser():SendToScripts("Respond", false)
end

function CMenuMonstersScript:SelectMonster(index)
	self:GetEntity():GetUser():SendToScripts("Respond", index)
end

function CMenuMonstersScript:UpdateMonsters()
	if IsServer() then 
		self:SendToLocal("UpdateMonsters")
		return
	end
	
	local monsters = self.monstersController:GetParty()
	local data = {}
	
	local inBattle = self:GetEntity().battleScreenScript.inBattle
	local deployedIndex = self:GetEntity().battleScreenScript.myMonsterIndex
	
	for i=1,6 do 
		local mon = monsters[i]
		local d
		if mon then 
			table.insert(data, mon:ForWidget())
		else 
			table.insert(data, {})
		end
	end
	
	if inBattle and deployedIndex > 0 then 
		data[deployedIndex].active = true
	end
	
	self.widget.js.data.inventory = data
end

return CMenuMonstersScript
