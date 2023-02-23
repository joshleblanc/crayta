local BeeboxScript = {}

-- Script properties are defined here
BeeboxScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "beeTemplate", type = "template" },
	{ name = "beeSpawnLocation", type = "entity" },
	{ name = "worldBox", type = "entity" },
}

--This function is called on the server when this entity is created
function BeeboxScript:Init()
	self:Schedule(function()
		while true do 
			Wait(60)
			
			local bees = GetWorld():FindAllScripts("beeScript")
			if #bees < 20 then 
				local bee = GetWorld():Spawn(self.properties.beeTemplate, self.properties.beeSpawnLocation)
				bee:SendToScripts("Reattach", self.properties.worldBox)
			end
		end
	end)
end

function BeeboxScript:HandleDropoff()
	local bee = GetWorld():Spawn(self.properties.beeTemplate, self.properties.beeSpawnLocation)
	bee:SendToScripts("Reattach", self:GetEntity())
	bee:SendToScripts("Enable")
	
	self:Schedule(function()
		Wait(60)
		bee:SendToScripts("Reattach", self.properties.worldBox)
		bee:SendToScripts("Enable")
	end)
end

return BeeboxScript
