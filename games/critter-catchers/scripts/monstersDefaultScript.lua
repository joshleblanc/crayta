local MonstersDefaultScript = {}

-- Script properties are defined here
MonstersDefaultScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "startingMonster", type = "template" },
}

--This function is called on the server when this entity is created
function MonstersDefaultScript:Init()
	self:GetEntity():SendToScripts("UseDb", "monsters", function(db)
		local existingRecord = db:FindOne()
		if not existingRecord then 
			local mc = GetWorld():FindScript("entityCacheScript")
			local mon = mc:FindEntityByTemplate(self.properties.startingMonster).monsterScript
			
			mon:SeedIvs()
			mon:SetLevel(3)
			
			mon:ComputeStats()
			mon:ResetHp()
			
			db:InsertOne(mon:ToTable())
		end
	end)
end

return MonstersDefaultScript
