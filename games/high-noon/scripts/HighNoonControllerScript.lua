local HighNoonControllerScript = {}

HighNoonControllerScript.Properties = {
	{ name = "onDestroy", type = "event", tooltip = "Called when destroy phase begins" },
	{ name = "onSearch", type = "event", tooltip = "Called when search phase begins" },
	{ name = "highNoonColor", type = "colorgradingasset" },
	{ name = "defaultColor", type = "colorgradingasset" },
	{ name = "searchDuration", type = "number", default = 30 },
	{ name = "destroyDuration", type = "number", default = 30 },
	{ name = "transitionTime", type = "number", default = 5 },
	{ name = "state", type = "number", default = 0, editable = false },
	{ name = "armedGrip", type = "gripasset"},
	{ name = "unarmedGrip", type = "gripasset"},
	{ name = "gunTemplate", type = "template" },
	{ name = "ammoTemplate", type = "template" },
	{ name = "dropSpread", type = "number", default = 600 },
	{ name = "running", type = "boolean", default = false },
	{ name = "endDestroyEarly", type = "boolean", default = true, tooltip = "Turn off for debugging purposes" }

}

--This function is called on the server when this entity is created
function HighNoonControllerScript:Init()
	self:Reset()
end


function HighNoonControllerScript:PauseMultiplayer()
	self.properties.running = false
	if self.schedule then
		Print("Canceling the multiplayer schedule")
		self:Cancel(self.schedule)
	end
end

function HighNoonControllerScript:Run()
	self.properties.running = true
	if self.schedule then
		self:Cancel(self.schedule)
	end
	
	GetWorld():ForEachUser(function(user)
		self:ResetAmmo(user)
	end)
	
	self:Search()
end

function HighNoonControllerScript:ResetAmmo(userEntity, fromEntity, selfMsg, otherMsg, youKilledMsg) 
	local player = userEntity:GetPlayer()
	if not player then return end
	local heldEntity = player:FindScriptProperty("heldEntity")
	
	if heldEntity and heldEntity:GetTemplate() == self.properties.gunTemplate then
		heldEntity.gunScript.properties.currentShotsInClip = 0
	end
	local item = player:GetUser().inventoryScript:FindItemForTemplate(self.properties.gunTemplate)
	item.data.currentShotsInClip = 0
end

function HighNoonControllerScript:DropAmmo(userEntity, fromEntity, selfMsg, otherMsg, youKilledMsg)
	local centerPosition = userEntity:GetPlayer():GetPosition()
	local item = userEntity.inventoryScript:FindItemForTemplate(self.properties.gunTemplate)
	local currentShotsInClip = item.data.currentShotsInClip or 0

	local spread = self.properties.dropSpread
	local spreadHalf = self.properties.dropSpread / 2
	self:Schedule(function()
		for i=1,currentShotsInClip do
			--local newPosition = centerPosition + Vector.New((math.random() * spread) - spreadHalf, (math.random() * spread) - spreadHalf, -40)
			local newPosition = centerPosition
			local entity = GetWorld():Spawn(self.properties.ammoTemplate, newPosition, Rotation.Zero)

			local script = entity:FindScript("pickupSpawnerScript", true)
			script:ShowPickup()
			script.properties.singlePickup = true
			
			entity:SendToScripts("Fly")
			
			print("Spawned ammo at", newPosition)
			Wait()
		end
	end)
end


function HighNoonControllerScript:Search()
	print("Starting search")
	GetWorld().colorGrading = self.properties.defaultColor
	self:MoveToTime(0)
	self.properties.state = 0

	self.properties.onSearch:Send()
	self.schedule = self:Schedule(function()
	
		-- Disabled: start search timer after someone picks up ammo
		--while self:ShouldEndHighNoon() do
		--	Wait()
		--end
		
		Wait(self.properties.searchDuration)

		print("Done search")
		
		if self.properties.running then 
			self:Destroy()
		end
	end)
end

function HighNoonControllerScript:Destroy()
	print("Starting Destroy")
	GetWorld().colorGrading = self.properties.highNoonColor
	
	self:MoveToTime(0.5)
	self.properties.state = 1
	
	self.properties.onDestroy:Send()
	
	local count = 0
	self.schedule = self:Schedule(function()
		local shouldEndHighNoon = self:ShouldEndHighNoon()
		while not shouldEndHighNoon and count < self.properties.destroyDuration do
			local dt = Wait()
			count = count + dt
			shouldEndHighNoon = self:ShouldEndHighNoon()
		end
		
		if shouldEndHighNoon then
			print("End early")
			self:Schedule(function()
				GetWorld():ForEachUser(function(user)
					print("Notify {1}", user:GetUsername())
					user:SendToScripts("ShowLocation", { label = "Night will fall soon...", title = "Everyone is out of ammo" })
				end)
				
				Wait(3)
				if self.properties.running then
					print("Running search")
					self:Search()
				end
			end)
		else
			if self.properties.running then
				self:Search()
			end
		end
	end)
end

function HighNoonControllerScript:IsSearch() 
	return self.properties.state == 0
end

function HighNoonControllerScript:IsDestroy()
	return self.properties.state == 1
end

function HighNoonControllerScript:IsRunning()
	return self.properties.running
end

function HighNoonControllerScript:MoveToTime(target)

	-- Fast sun transitions look better on the client because
	-- the server is locked to 30fps.
	-- We still want to run it on the server so anyone that joins mid-game
	-- still has a consistent state
	if IsServer() then
		self:SendToAllClients("MoveToTime", target)
	end
	self:Schedule(function()
		local startTime = GetWorld():GetTimeOfDay()
		
		-- if the target is in the past, make it in tomorrow
		if target < startTime then
			target = target + 1
		end
		
		local amount = target - startTime
		local time = 0
		local percentage = 0
		
		-- loop until we're at the desired time
		while percentage < 1 do
			local dt = Wait()
	  	time = time + dt
			
			-- this is the progress of the transition
			percentage = time / self.properties.transitionTime
			local newTime = startTime + (amount * percentage)
		
			GetWorld().startTime = newTime % 1
			
			-- Directly tie the fog density to the time of day
			local fogDensity = math.abs(math.sin(1 - newTime) * 2  - 1)
			if self:IsDestroy() then
				fogDensity = 0
			end

			GetWorld().heightFogDensity = fogDensity
		end
	end)
end

function HighNoonControllerScript:Reset()
	-- 0 = search
	-- 1 = destroy
	self.properties.state = 0
	GetWorld().colorGrading = self.properties.defaultColor
	self:Run()
end

function HighNoonControllerScript:AlertUsers(text,time)
	GetWorld():ForEachUser(
		function(userEntity)
			userEntity:SendToScripts("Shout", text, time)
			self:SetPlayerArmedStatus(userEntity)
		end
	)
end
--[[
						Removed - does not appear to be used.
						*************************************
function HighNoonControllerScript:SetPlayerArmedStatus(userEntity)
print("Testing to see if this is called at all")
	if userEntity:GetPlayer():IsValid() then
		if self.properties.state == 0 then 
			local grip = self.properties.unarmedGrip
			userEntity:GetPlayer():SendToScripts("ChangeGrip",grip,self.properties.state)
		elseif self.properties.state == 1 then
			local grip = self.properties.armedGrip
			userEntity:GetPlayer():SendToScripts("ChangeGrip",grip,self.properties.state)
		end	
	end
end
--]]
function HighNoonControllerScript:ShouldEndHighNoon()
	if not self.properties.endDestroyEarly then return false end 

	local sum = 0
	GetWorld():ForEachUser(function(user)
		local player = user:GetPlayer()
		if player then
			local heldEntity = player:FindScriptProperty("heldEntity")
			if heldEntity and heldEntity:GetTemplate() == self.properties.gunTemplate then 
				local gunScript = heldEntity.gunScript
				if gunScript then
					sum = sum + gunScript.properties.currentShotsInClip
				end
			else
				local item = player:GetUser().inventoryScript:FindItemForTemplate(self.properties.gunTemplate)
				local currentShotsInClip = item.data.currentShotsInClip or 0
				sum = sum + currentShotsInClip 
			end
		end
	end)
	return sum == 0
end

 
return HighNoonControllerScript
