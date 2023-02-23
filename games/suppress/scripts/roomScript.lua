local RoomScript = {}

-- Script properties are defined here
RoomScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "input", type = "entity" },
	{ name = "outputs", type = "entity", container = "array" },
	{ name = "cameraRotation", type = "number", default = -90 },
	{ name = "yAlignment", type = "entity" }
}

--This function is called on the server when this entity is created
function RoomScript:Init()
	self.doors = self:GetEntity():FindAllScripts("roomDoorScript", true)
	
	local enemies = self:GetEntity():FindAllScripts("monsterScript", true)
	self.enemies = {}
	for _, enemy in ipairs(enemies) do
		table.insert(self.enemies, enemy:GetEntity())
	end
end

function RoomScript:GetEnemies()
	for i=#self.enemies,1,-1 do 
		local enemy = self.enemies[i]
		if not Entity.IsValid(enemy) then 
			table.remove(self.enemies, i)
		end
	end
	
	return self.enemies
end

return RoomScript
