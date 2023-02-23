local Spawner = {}

-- Script properties are defined here
Spawner.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "thingsToSpawn", type = "template", container = "array" }
}

--This function is called on the server when this entity is created
function Spawner:Init()
	self.spawnTime = 1
	self.blueCountdown = 30
	self.greenCountdown = 15
	self.timeUntilSpawn = 0
	self.spawns = {}
end

function Spawner:GetSpawnPosition()
	local distance = 5000
	local angle = (math.random() * math.pi * 2) - math.pi

	local spawnPosition = Vector.New(math.cos(angle), math.sin(angle), 0) * distance
	spawnPosition.z = 50
	return spawnPosition
end

function Spawner:GetSequentialSpawnPosition()
	local distance = 5000
	
	local increment = (self.spawnSequence * 10) % 360
	local angle = ((increment / 360) * math.pi * 2) - math.pi


	local spawnPosition = Vector.New(math.cos(angle), math.sin(angle), 0) * distance
	spawnPosition.z = 50
	
	self.spawnSequence = self.spawnSequence + 1
	
	return spawnPosition
end

function Spawner:Start()

	if not IsServer() then
		return
	end

	
	local time = 0
	self.spawnSequence = 0
	
	self.handle = self:Schedule(function()
	
		while(true) do
		
			local dt = Wait()
			time = time + dt
			
			self.timeUntilSpawn = self.timeUntilSpawn - dt
			if (self.timeUntilSpawn < 0) then
				
				local arr = self:GetEntityArray(time)
				
				for k, v in pairs(arr) do
					local pos = self:GetSpawnPosition()
					if v == self.properties.thingsToSpawn[3] then 
						pos = self:GetSequentialSpawnPosition()
					end
					local entity = GetWorld():Spawn(v, pos, Rotation.New(0, 0, 0))
					table.insert(self.spawns, entity)
				
					if #self.spawns > 250 then
						table.remove(self.spawns, 1):Destroy()
					end
				end
				self.timeUntilSpawn = self.spawnTime
			end
			self.greenCountdown = self.greenCountdown - dt
			self.blueCountdown = self.blueCountdown - dt
		end
	end)
end

function Spawner:GetEntityArray(time)
	local things = self.properties.thingsToSpawn

	if time < 30 then
		return { things[1] }
	elseif time < 60 then
		return { things[1], things[2] }
	elseif time < 90 then
		return { things[1], things[2], things[3] }
	elseif time < 120 then
		return { things[1], things[2], things[3], things[3] }
	elseif time < 150 then
		return { things[1], things[1], things[2], things[2], things[3], things[3] }
	else 
		return { things[1], things[1], things[1], things[2], things[2], things[2], things[3], things[3], things[3] }
	end
	
end

function Spawner:Stop()
	if not IsServer() then
		self:SendToServer("Stop")
		return
	end
	self:Reset()
	self.greenCountdown = 15
	self.blueCountdown = 30
	if self.handle then
		self:Cancel(self.handle)
	end
end

function Spawner:Reset()
	if not IsServer() then
		return
	end
	
	for k, v in ipairs(self.spawns) do
		v:Destroy()
	end
	self.spawns = {}
	self.timeUntilSpawn = self.spawnTime	
end


return Spawner
