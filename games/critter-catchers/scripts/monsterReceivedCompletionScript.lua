local MonsterReceivedCompletionScript = {}

-- Script properties are defined here
MonsterReceivedCompletionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "monster", type = "template" },
	{ name = "onComplete", type = "event" },
}

--This function is called on the server when this entity is created
function MonsterReceivedCompletionScript:Init()
	self:Schedule(function()
		local player = self:GetEntity():GetPlayer()
		while not player do 
			Wait()
			player = self:GetEntity():GetPlayer()
		end
		
		print("listening for monster added")
		player:FindScript("playerMonstersControllerScript", true).properties.onMonsterAdded:Listen(self, "HandleMonsterAdded")
	end)
end

function MonsterReceivedCompletionScript:HandleMonsterAdded(monster)
	print("Handling monster added", monster, self.properties.monster)
	if monster == self.properties.monster then 
		print("Sending")
		self.properties.onComplete:Send()
	end
end

return MonsterReceivedCompletionScript
