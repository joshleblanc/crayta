local MonsterLevelUpDebugScript = {}

-- Script properties are defined here
MonsterLevelUpDebugScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "active", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function MonsterLevelUpDebugScript:Init()
	if not self.properties.active then return end 
	
	local c = self:GetEntity():FindScript("playerMonstersControllerScript", true)
	self:Schedule(function()
		while true do 
			Wait(10)
			
			local m = c:GetMonsters()[1]
			local s = m:GetEntity():FindScript("statsScript")
			print(s:GetStat("level"):Level(), s:GetStat("level"):RequiredXp())
			s:LevelUp("level")
			
			--s:Print()
		end
	end)
end

return MonsterLevelUpDebugScript
