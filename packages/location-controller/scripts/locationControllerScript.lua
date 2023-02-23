local LocationControllerScript = {}

-- Script properties are defined here
LocationControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "defaultLocation", type = "template" },
	{ name = "defaultSpawnLocation", type = "string" },
	{ name = "distance", type = "number", default = 10000, tooltip = "How far away to spawn new locations from each other" },
	{ name = "debug", type = "boolean" },
	{ name = "liftLocations", type = "boolean", visibleIf = function(p) return p.debug end },
	{ name = "permanentLocations", type = "template", container = "array" }
}

function LocationControllerScript:Init()
	-- This is an array of the active location instances
	self.activeLocations = {}
	
	self:CollectExistingLocations()
	
	self:Schedule(function()
		for i=1,#self.properties.permanentLocations do 
			local template = self.properties.permanentLocations[i]
			if not self:FindLocationByTemplate(template) then 
				self:SpawnLocation(template)
			end
			
			Wait()
		end
	end)
end

function LocationControllerScript:CollectExistingLocations()
	local locations = GetWorld():FindAllScripts("locationScript")
	for _, location in ipairs(locations) do 
		local position = self:GetNewInstancePosition()
		local entity = location:GetEntity()
		entity:SetPosition(position)
		entity:SetRotation(Rotation.Zero)
		table.insert(self.activeLocations, entity)
	end
end

function LocationControllerScript:Debug(input, ...)
	if not self.properties.debug then return end 
	
	printf("LocationController: " .. input, ...)
end

-- Either get an existing template or spawn a new one
function LocationControllerScript:SpawnLocation(locationTemplate) 
	local activeLocation = self:GetActiveLocation(locationTemplate)
	if not activeLocation or activeLocation:FindScriptProperty("uniqueInstance") then 
		local position = self:GetNewInstancePosition()
		
		self:Debug("Spawning {1} at {2}", locationTemplate:GetName(), position)
		
		activeLocation = GetWorld():Spawn(locationTemplate, position, Rotation.Zero)
		table.insert(self.activeLocations, activeLocation)
	end
	return activeLocation
end

function LocationControllerScript:MovePlayer(user, locationTemplate, spawnLocationId, cb)
	if not IsServer() then 
		self:SendToServer("MovePlayer", user, locationTemplate, spawnLocationId)
		return
	end

	local prevLocation = user.userLocationScript:ActiveLocation()
	local prevLocationEntity = user.userLocationScript:ActiveLocationEntity()
	
	if locationTemplate:FindScriptProperty("redirectsTo") then 
		spawnLocationId = locationTemplate:FindScriptProperty("redirectsToSpawn")
		locationTemplate = locationTemplate:FindScriptProperty("redirectsToLocation")
	end
	
	local activeLocation = self:SpawnLocation(locationTemplate)
		
	self:Schedule(function()
		-- If we don't wait for the next frame, none of the newly spawned location entities will be valid 
		-- for example, trying to move the player to the position of one of the spawn locators would just fail silently
		Wait()
		
		-- If we don't wait a _second_ frame, passing entities that exist in the newly spawned location via parameters will fail
		Wait()
		
		
		-- save the location of the user so we can spawn them in the correct location when they login
		user.userLocationScript:SetLocation(
			activeLocation.locationScript.properties.id,
			spawnLocationId,
			activeLocation
		)
				
		if not activeLocation:FindScriptProperty("noRespawn") then 
			user.userLocationScript:SetSpawnLocation(
				activeLocation.locationScript.properties.id,
				spawnLocationId
			)
		end
		
		Wait(1)
		
		
		
		activeLocation:SendToScripts("TrySetOwner", user)
		
		activeLocation:SendToScripts("ShowForUser", user)
		
		cb()
		
		prevLocationEntity:SendToScripts("OnPlayerLeave", user)
		
		self:DestroyIfInactive(prevLocationEntity)
		
		if Entity.IsValid(prevLocationEntity) and prevLocationEntity ~= activeLocation  then 
			prevLocationEntity:SendToScripts("HideForUser", user)
		end
		
		Wait()
		
		self:Debug("Spawning player {1}", activeLocation:GetName())

		activeLocation:SendToScripts("SpawnPlayer", user, spawnLocationId)
		
		while not user:IsLocalReady() do 
			Wait()
		end
		
		activeLocation:SendToScripts("OnPlayerEnter", user)
		activeLocation:SendToScripts("ApplySettings", user)
	end)	
end

function LocationControllerScript:DestroyAllInactive()
	for i, location in ipairs(self.activeLocations) do
		self:DestroyIfInactive(location:FindScript("locationScript").properties.id)
	end
end

function LocationControllerScript:IsPermanent(template)
	for i=1,#self.properties.permanentLocations do 
		if self.properties.permanentLocations[i] == template then 
			return true
		end
	end
	return false
end

function LocationControllerScript:DestroyIfInactive(locationEntity)

	if self:IsPermanent(locationEntity:GetTemplate()) then 
		return
	end

	self:Debug("Removing {1}", locationId)
	local isInactive = true 
	
	GetWorld():ForEachUser(function(user)
		local currLocation = user.userLocationScript.properties.locationEntity
		if currLocation == locationEntity then 
			isInactive = false
		end
	end)
	
	if not isInactive then return end 
	
	local indexToRemove, locationInstance = self:FindLocationByEntity(locationEntity)
	
	if not locationInstance then return end 
	
	self:Debug("Location is inactive, removing {1}", locationInstance:GetName())
	table.remove(self.activeLocations, indexToRemove)
	locationInstance:Destroy()
	self:Debug("Location has been removed")
end

function LocationControllerScript:FindLocationByTemplate(template)
	for i, location in ipairs(self.activeLocations) do
		if location:GetTemplate() == template then 
			return i, location
		end
	end
end

function LocationControllerScript:FindLocationByEntity(entity)
	for i, location in ipairs(self.activeLocations) do
		if location == entity then 
			return i, location
		end
	end
end

function LocationControllerScript:FindActiveLocationById(id)
	for i, location in ipairs(self.activeLocations) do
		if location:FindScript("locationScript").properties.id == id then 
			return i, location
		end
	end
end

function LocationControllerScript:GetNewInstancePosition()
	-- When we spawn a new location, we have to move it far enough away 
	-- from other locations that they can't be seen
	local newPosition = Vector.Zero
	local validPosition = nil
	
	while not validPosition do 
		newPosition.x = newPosition.x + self.properties.distance
		
		if not self:IsPositionOccupied(newPosition) then 
			validPosition = newPosition
		end
	end
	
	if self.properties.debug and self.properties.liftLocations then 
		validPosition.z = self.properties.distance
	end
	
	return validPosition
end

function LocationControllerScript:IsPositionOccupied(position)
	for _, location in ipairs(self.activeLocations) do
		if location:GetPosition() == position then 
			return true
		end
	end
	
	return false
end

function LocationControllerScript:GetActiveLocation(locationTemplate)
	for _, locationInstance in ipairs(self.activeLocations) do 
		if locationInstance:GetTemplate() == locationTemplate then 
			return locationInstance
		end
	end
	
	return false
end

function LocationControllerScript:HandleSaveDataReady(user)
	local prevLocation = user.userLocationScript:SpawnLocation()

	local template = self.properties.defaultLocation
	if prevLocation then 
		template = GetWorld():FindTemplate(prevLocation) or self.properties.defaultLocation
	end
	
	local spawnLocation = user.userLocationScript:SpawnPoint() or self.properties.defaultSpawnLocation
	
	if template:FindScriptProperty("redirectsTo") then 
		spawnLocation = template:FindScriptProperty("redirectsToSpawn")
		template = template:FindScriptProperty("redirectsToLocation")
	end

	local location = self:SpawnLocation(template)
	
	user.userLocationScript:SetSpawnLocation(location:FindScriptProperty("id"), spawnLocation)
	user.userLocationScript:SetLocation(location:FindScriptProperty("id"), spawnLocation, location)
	
	self:Debug("Sending try set owner")
	location:SendToScripts("TrySetOwner", user)
	location:SendToScripts("ShowForUser", user)
	
	self:Schedule(function()
		Wait()
		
		location:SendToScripts("SpawnPlayer", user, spawnLocation)
		
		while not user:IsLocalReady() do 
			Wait()
		end
		
		location:SendToScripts("OnPlayerEnter", user)
		location:SendToScripts("ApplySettings", user)
	end)	
end

function LocationControllerScript:OnUserLogin(user)
	if user.saveDataScript.data then 
		self:HandleSaveDataReady(user)
	else 
		user.saveDataScript.properties.onSaveDataReady:Listen(self, "HandleSaveDataReady")
	end
end

return LocationControllerScript
