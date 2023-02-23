local UserLocationScript = {}

-- Script properties are defined here
UserLocationScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "locationEntity", type = "entity", editable = false },
	{ name = "locationId", type = "string", editable = false },
	{ name = "debug", type = "boolean", default = false },
	{ name = "onSetLocation", type = "event" }
}

--This function is called on the server when this entity is created
function UserLocationScript:Init()
	self.locationController = GetWorld():FindScript("locationControllerScript")
end

function UserLocationScript:LocalInit()
	self:Init()
end

function UserLocationScript:Debug(input, ...)
	if not self.properties.debug then return end 

	printf("UserLocationScript: " .. input, ...)
end

function UserLocationScript:IsAt(locationId) 
	return self:ActiveLocation() == locationId
end

function UserLocationScript:GoBack()
	local prevLocation = GetWorld():FindTemplate(self:LastLocation())
	
	self:GoTo(prevLocation, self:LastLocationSpawnLocation())
end

function UserLocationScript:GoTo(locationTemplate, spawn, sound)
	if not IsServer() then 
		self:SendToServer("GoTo", locationTemplate, spawn, sound)
		return
	end
	
	local user = self:GetEntity()

	user:GetPlayer():SetInputLocked(true)
	
	user:SendToScripts("DoScreenFadeOut", 1)
	self:Schedule(function()
		Wait(1)
		
		if sound then 
			self:PlaySoundLocally(sound)
		end
		
		self.locationController:MovePlayer(self:GetEntity(), locationTemplate, spawn, function()
			user:SendToScripts("DoScreenFadeIn", 1)
			user:GetPlayer():SetInputLocked(false)
		end)
		
	end)
end

function UserLocationScript:Respawn()
	self:GoTo(self:ActiveLocationTemplate(), self:ActiveLocationSpawnLocation())
end

function UserLocationScript:ActiveLocationTemplate()
	return self.properties.locationEntity:GetTemplate()
end

function UserLocationScript:PlaySoundLocally(sound)
	if IsServer() then 
		self:SendToLocal("PlaySoundLocally", sound)
		return
	end
	self:GetEntity():PlaySound2D(sound)
end

function UserLocationScript:ActiveLocationEntity()
	return self.properties.locationEntity
end

function UserLocationScript:ActiveLocation()
	return self:GetSaveData():GetData("activeLocationId")
end

function UserLocationScript:SpawnLocation()
	return self:GetSaveData():GetData("spawnLocationId")
end

function UserLocationScript:SpawnPoint()
	return self:GetSaveData():GetData("spawnPoint")
end

function UserLocationScript:ActiveLocationSpawnLocation()
	return self:GetSaveData():GetData("activeLocationSpawnLocation")
end

function UserLocationScript:LastLocation()
	return self:GetSaveData():GetData("lastLocationId") or self:ActiveLocation()
end

function UserLocationScript:LastLocationSpawnLocation()
	return self:GetSaveData():GetData("lastLocationSpawnLocation") or self:ActiveLocationSpawnLocation()
end

function UserLocationScript:GetSaveData()
	if not self.saveData then 
		self.saveData = self:GetEntity().saveDataScript
	end
	return self.saveData
end

function UserLocationScript:IsDifferentLocation(id) 
	return id ~= self:ActiveLocation()
end

function UserLocationScript:SetSpawnLocation(locationId, spawnLocation)
	self:GetSaveData():SaveData("spawnLocationId", locationId)
	self:GetSaveData():SaveData("spawnPoint", spawnLocation)
end

function UserLocationScript:SetLocation(locationId, spawnLocation, locationEntity)
	if not self:IsDifferentLocation(locationId) and self.properties.locationEntity then return end 
	
	self:GetSaveData():SaveData("lastLocationId", self:ActiveLocation())
	self:GetSaveData():SaveData("lastLocationSpawnLocation", self:ActiveLocationSpawnLocation())
	self:GetSaveData():SaveData("activeLocationId", locationId)
	self:GetSaveData():SaveData("activeLocationSpawnLocation", spawnLocation)
	
	self.properties.locationId = locationId
	
	self:Debug("Setting location entity {1}", locationEntity)
	self.properties.locationEntity = locationEntity
	
	self.properties.onSetLocation:Send(locationId, spawnLocation, locationEntity)
end

return UserLocationScript
