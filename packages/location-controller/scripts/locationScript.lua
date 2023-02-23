local LocationScript = {}


function redirects(p)
	return p.redirectsTo
end
-- Script properties are defined here
LocationScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string", tooltip = "A unique id for the location", editable = false },
	{ name = "name", type = "text", tooltip = "The name of the location" },
	{ name = "uniqueInstance", type = "boolean", tooltip = "If checked, this location will spawn regardless of whether or not one already exists in the world" },
	{ name = "playerTemplate", type = "template" },
	{ name = "owner", type = "entity", editable = false }, -- while a location doesn't technically have an owner, this represents the person who triggered the spawn
	{ name = "noRespawn", type = "boolean", default = false },
	{ name = "onLocationSpawn", type = "event" },
	{ name = "onPlayerEnter", type = "event" },
	{ name = "onPlayerExit", type = "event" },
	{ name = "redirectsTo", type = "boolean" },
	{ name = "redirectsToLocation", type = "template", visibleIf=redirects },
	{ name = "redirectsToSpawn", type = "string", visibleIf=redirects },
	{ name = "debug", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function LocationScript:Init()
	self.properties.id = self:GetEntity():GetTemplate():GetName()
	self.spawnLocations = self:GetEntity():FindAllScripts("locationSpawnPointScript", true)
end

function LocationScript:Debug(input, ...)
	printf("LocationScript: " .. input, ...)
end

function LocationScript:ClientInit()
	self.invisibles = {}
	self.invisiblesInitialized = false
	
	local user = GetWorld():GetLocalUser()
	
	--self:InitializeInvisibles()
	
	self:Schedule(function()
		if user.userLocationScript:IsAt(self.properties.id) then 
			self:Show()
		else
			self:Hide()
		end
	end)
end

function LocationScript:InitializeInvisibles()
	if self.invisiblesInitialized then return end 
	
	self:CheckVisibles(self:GetEntity())
	
	self.invisiblesInitialized = true
end

function LocationScript:CheckVisibles(root)
	if not root.visible then 
		self.invisibles[root:GetName()] = true
	end
	
	for _, entity in ipairs(root:GetChildren()) do 
		self:CheckVisibles(entity)
	end
end

function LocationScript:CanMakeVisible(entity)
	if not self.invisiblesInitialized then 
		self:InitializeInvisibles()
	end
	
	return not self.invisibles[entity:GetName()]
end

function LocationScript:HideForUser(user)
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "Hide")
		return
	end
end

function LocationScript:ShowForUser(user)
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "Show")
		return
	end
end

function LocationScript:Hide(root)
	root = root or self:GetEntity()
	
	self:InitializeInvisibles()
	
	if not root:IsA(NPC) then 
		root.visible = false 
	end
	
	for _, child in ipairs(root:GetChildren()) do 
		self:Hide(child)
	end
end

function LocationScript:Show(root)
	root = root or self:GetEntity()
	
	self:InitializeInvisibles()
	
	if self:CanMakeVisible(root) then 
		root.visible = true 
	else
		self:Debug("Cannot make {1} visible", root:GetName())
	end
	
	for _, child in ipairs(root:GetChildren()) do 
		self:Show(child)
	end
end

function LocationScript:TrySetOwner(user)
	self:Debug("Setting owner")
	if self.properties.owner then return end 
	
	self:Debug("Setting owner success")
	
	self.properties.owner = user
	
	self.properties.onLocationSpawn:Send(user)
end

function LocationScript:SpawnPlayer(user, spawnLocation, cb)
	local chosenLocation = self:GetSpawnLocationFromId(spawnLocation)
	user:SpawnPlayerWithEffect(self.properties.playerTemplate, chosenLocation:GetEntity(), function()
		self:Schedule(function()
			Wait()
			
			local player = user:GetPlayer()
			local cameraType = player.cameraType
			player.cameraType = 1
			
			Wait()
			
			player.cameraType = cameraType
			
			if cb then 
				cb()
			end
			
		end)
	end)
end

function LocationScript:GetSpawnLocationFromId(spawnLocationId)
	for _, spawnLocation in ipairs(self.spawnLocations) do 
		if spawnLocation.properties.id == spawnLocationId then 
			return spawnLocation
		end
	end
	return self.spawnLocations[1]
end

function LocationScript:MovePlayer(player, spawnLocation)
	local chosenLocation = self:GetSpawnLocationFromId(spawnLocation)

	player:SetPosition(chosenLocation:GetEntity():GetPosition())
end

function LocationScript:AdjustPlayerVisibility()
	self:Schedule(function()
		
		local localUser = GetWorld():GetLocalUser()
		local userLoc = localUser.userLocationScript:ActiveLocation()
		
		GetWorld():ForEachUser(function(user)
			if not user then return end
			local player = user:GetPlayer()
			if not player then return end 
			
			player.visible = user:FindScriptProperty("locationId") == userLoc
		end)
	end)
end

function LocationScript:OnPlayerEnter(user)
	self:SendToAllClients("AdjustPlayerVisibility")
	self.properties.onPlayerEnter:Send(user)
end

function LocationScript:OnPlayerLeave(user)
	self:SendToAllClients("AdjustPlayerVisibility")
	self.properties.onPlayerExit:Send(user)
end

return LocationScript
