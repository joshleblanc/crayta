local NpcDestroyerScript = {}

-- Script properties are defined here
NpcDestroyerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "location", type = "entity" }
}

--This function is called on the server when this entity is created
function NpcDestroyerScript:Init()
	self:Schedule(function()
		while not self.properties.location do 
			Wait()
		end
		self.properties.location.onDestroy:Listen(self, "HandleLocationDestroy")
	end)
end

function NpcDestroyerScript:SetLocation(location)
	self.properties.location = location
end

function NpcDestroyerScript:HandleLocationDestroy()
	self:GetEntity():Destroy()
end

return NpcDestroyerScript
