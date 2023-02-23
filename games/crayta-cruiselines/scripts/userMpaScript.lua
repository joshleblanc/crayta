local UserMapScript = {}

-- Script properties are defined here
UserMapScript.Properties = {
	{ name = "bounds", type = "entity" },
	{ name = "stairs", type = "entity" },
	{ name = "enabled", type = "boolean", default = true },
	{ name = "eventsController", type = "entity" }
}

--This function is called on the server when this entity is created
function UserMapScript:Init()
end

function UserMapScript:Disable()
	self:Close()
	if not IsServer() then
		self:SendToServer("Disable")
		return
	end
	
	self.properties.enabled = false
end

function UserMapScript:Enable()
	if not IsServer() then
		self:SendToServer("Enable")
		return
	end
	
	self.properties.enabled = true
end

function UserMapScript:Close()
	if IsServer() then
		self:SendToLocal("Close")
		return
	end

	self.open = false
	self.widget:Hide()
end

function UserMapScript:HandleBoundsLoaded()
	if IsServer() then 
		self:SendToLocal("HandleBoundsLoaded")
		return	
	end
	
	print("Loading bounds")
	
	self:Schedule(function()
		while not self.widget do
			Wait()
		end
		
		print("Good to go")
		self.widget.js.data.bounds = self:GetBounds()
	end)
end

function UserMapScript:LocalInit()
	self.entity = self:GetEntity()
	self.widget = self.entity.userMapWidget
	self.world = GetWorld()
	self.width = 20000 
	self.height = 20000--3175 
	
	self.xOffset = 6500
	self.yOffset = -5641
	
	self.floor = 1
	
	self.locations = self.world:FindAllScripts("showLocationScript")

	self:Schedule(function()
		while true do 
			Wait(10)
			self.locations = self.world:FindAllScripts("showLocationScript")
		end
	end)	
	
	local stairIndicators = self.properties.stairs:GetChildren()
	local stairs = {}
	
	for _, stair in ipairs(stairIndicators) do
		local pos = stair:GetPosition()
		
		table.insert(stairs, {
			x = (pos.x + self.xOffset) / self.width,
			y = (pos.y + self.yOffset) / self.height,
			floor = stair:FindScriptProperty("floor")
		})
	end
	
	self.widget.js.data.stairs = stairs
	self:UpdateLocations()
	self:UpdateEvents()
	self:Close()
end

function UserMapScript:UpdateLocations()
	if IsServer() then
		self:SendToLocal("UpdateLocations")
		return
	end
	
	-- If we update immediately, then the room's title isn't set yet.
	-- this is a stupid solution
	self:Schedule(function()
		Wait(1)
		self.widget.js.data.locations = self:GetLocations()
	end)
	
	
end

function UserMapScript:UpdateEvents()
	if IsServer() then
		self:SendToLocal("UpdateEvents")
		return
	end
	
	-- If we update immediately, event properties aren't on the client yet
	-- this is a stupid solution
	self:Schedule(function()
		Wait(1)
		self.widget.js.data.events = self:GetEvents()
	end)
end

function UserMapScript:_CollectBounds(root, arr)
	local children = root:GetChildren()
	
	if #children > 0 then
		for _, v in ipairs(children) do
			self:_CollectBounds(v, arr)
		end
	else
		table.insert(arr, root)
	end
	
	return arr
end

function UserMapScript:CollectBounds(root)
	return self:_CollectBounds(root, {})
end

function UserMapScript:GetBounds()
	local boundsPoints = self:CollectBounds(self.properties.bounds)
	local bounds = {}
	
	for _, point in ipairs(boundsPoints) do
		local pos = point:GetPosition()
		table.insert(bounds, {
			x = (pos.x + self.xOffset) / self.width,
			y = (pos.y + self.yOffset) / self.height,
			order = point:FindScriptProperty("order"),
			floor = point:FindScriptProperty("floor")
		})
	end
	
	return bounds
end

function UserMapScript:HandleFloorChange(player, f)
	if player:GetUser() ~= self:GetEntity() then return end 
	
	if IsServer() then
		self:SendToLocal("HandleFloorChange", player, f)
		return
	end
	
	self.widget.js.data.floor = f
	self.floor = f
end

function UserMapScript:LocalOnTick()
	if not self.open then return end 

	self.widget.js.data.players = self:GetPlayers()
end

function UserMapScript:GetEvents()
	local events = {}
	for _, event in ipairs(self.properties.eventsController.eventsControllerScript.events) do
		local loc = event.properties.locator:GetPosition()
		table.insert(events, {
			x = (loc.x + self.xOffset) / self.width,
			y = (loc.y + self.yOffset) / self.height,
			floor = event.properties.floor,
			active = event:IsActive(),
			upcoming = event:IsUpcoming(),
			inactive = not (event:IsActive() or event:IsUpcoming())
		})
	end
	return events
end

function UserMapScript:UpcomingEvents()
	local events = {}
	for _, event in ipairs(self.properties.eventsController.eventsControllerScript.events) do
		if event:IsUpcoming() then
			local loc = event.properties.locator:GetPosition()
			table.insert(events, {
				x = (loc.x + self.xOffset) / self.width,
				y = (loc.y + self.yOffset) / self.height,
				floor = event.properties.floor
			})
		end
	end
	return events
end

function UserMapScript:GetPlayers()
	local players = {}
		
	self.world:ForEachUser(function(user)
		local playerData = self:GetPlayerData(user)
		if playerData then
			table.insert(players, playerData)
		end
	end)
	
	return players
end

function UserMapScript:GetLocations()
	local locations = {}
	for _, v in ipairs(self.locations) do
		local entity = v:GetEntity()
		local pos = entity:GetPosition()
		table.insert(locations, {
			name = v.properties.title,
			width = entity.size.x / self.width,
			height = entity.size.y / self.height,
			x = (pos.x + self.xOffset) / self.width,
			y = (pos.y + self.yOffset) / self.height,
			angle = entity:GetRotation().yaw,
			floor = v.properties.floor
		})
	end
	return locations
end

function UserMapScript:GetButtonPrompts(prompts)
	if not self.properties.enabled then return end 
	
	if self.open then
		prompts.extra1 = "Close the map"
		
		if self.floor < 5 then
			prompts.interact = "Go up 1 floor"
		end
		
		if self.floor > 1 then
			prompts.extra2 = "Go down 1 floor"
		end
	else
		prompts.extra1 = "Open the map"
	end

end

function UserMapScript:LocalOnButtonPressed(btn)	
	if not self.properties.enabled then return end 

	if btn == "interact" and self.open then
		self.floor = self.floor + 1
	elseif btn == "extra2" and self.open then
		self.floor = self.floor - 1
	elseif btn == "extra1" then
		self.open = not self.open
		self.widget.visible = self.open
	end
	
	if btn == "interact" or btn == "extra2" then
		self.floor = math.clamp(self.floor, 1, 5)
		self.widget.js.data.floor = self.floor
	end
end

function UserMapScript:GetPlayerData(user)
	local player = user:GetPlayer()
	if player then
		local pos = player:GetPosition()
		local me = user == self.entity
		local rot 
		if me then
			local eye, lookAt = player:GetLookAt()
			local dir = (lookAt - eye):Normalize()
			rot = Rotation.FromVector(dir)
		else
			rot = Rotation.Zero
		end
		
		return {
			x = (pos.x + self.xOffset) / self.width,
			y = (pos.y + self.yOffset) / self.height,
			floor = player:FindScriptProperty("floor"),
			location = player:FindScriptProperty("location"),
			name = tostring(user:GetUsername()),
			yaw = rot.yaw,
			me = user == self.entity
		}
	else
		return nil
	end
end

return UserMapScript
