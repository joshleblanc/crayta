--[[
	A script to handle spawning and respawning pickups.
	Attach to a template to use that template as the pickup,
	or assign a template to the pickupTemplate field to make that the pickup.
	Works with the game script to reset on RoundStart.
	Can be configured to appear once in a game, or respawn after a given time.
]]

local PickupSpawnerScript = {}

-- Here are the properties that are exposed to the properties window in the editor
PickupSpawnerScript.Properties = {
	{ name = "pickupSound", type = "soundasset", },
	{ name = "useOnCollision", type = "boolean", default = false, },
	{ name = "rotateTime", type = "number", default = 0.0, editor = "seconds", },
	{ name = "respawning", type = "boolean", default = true, },
	{ name = "spawnTimeMin", type = "number", default = 60.0, editor = "seconds", },
	{ name = "spawnTimeMax", type = "number", default = 60.0, editor = "seconds", },
	{ name = "useSelfAsTemplate", type = "boolean", default = true, },
	{ name = "pickupTemplate", type = "template", visibleIf = function(p) return not p.useSelfAsTemplate end },
	{ name = "enableCollisionOnChildren", type = "boolean", default = true, },
	{ name = "showOnInit", type = "boolean", default = false, tooltip = "If false then won't show the pickup in the Init function and will wait for ShowPickup to be called by something else.", },
	{ name = "showOnInitInstantly", type = "boolean", default = true, visibleIf = function(p) return p.showOnInit end, tooltip = "If true and showOnInit is set then this will show instantly at start of game rather than using spawnTime", },
	{ name = "onPickup", type = "event", },
	{ name = "promptMsg", type = "text", },
	{ name = "singlePickup", type = "boolean", default = false, tooltip = "A single pickup will never respawn" },
	{ name = "root", type = "entity" },
	{ name = "recreate", type = "boolean", default = false }
}

-- this function is called when the entity this script is attached to is created at runtime
function PickupSpawnerScript:Init()
	if self.properties.showOnInit then
		if self.properties.showOnInitInstantly then
			self:ShowPickup()
		else
			self:ShowPickupAfterRespawnDelay()
		end
	else
		self:HidePickup()
	end
	self.initPosition = self.properties.root:GetPosition()
	self.initRotation = self.properties.root:GetRotation()
	self.initParent = self:GetEntity():GetParent()
	self.entities = self:CollectEntities(self.properties.root, {})
end

-- Helper for the Prompts package
function PickupSpawnerScript:GetInteractPrompt(prompts)
	local pickupTemplate = self:GetPickupTemplate()
	if pickupTemplate and not self.properties.useOnCollision then
		prompts.interact = self.properties.promptMsg:Format({name = pickupTemplate:FindScriptProperty("friendlyName") or ""})
	end
end

-- if a tool the player has in inventory is held then this is called
-- when the object is spawned, turn off an respawn/etc code in here
-- and just set it to visible / non-collidable (we basically just disable this script)
-- this allows us to use the script alongside an inventory to give the player this entity without it spawning a new one
function PickupSpawnerScript:OnHeld()
	
	self:SetVisibleAndCollision(true, false)

	if self.rotateTask then
		self:Cancel(self.rotateTask)
		self.rotateTask = nil
	end
	if self.respawnTask then
		self:Cancel(self.respawnTask)
		self.respawnTask = nil
	end
	
	self.held = true
	
end

-- Show the pickup5
function PickupSpawnerScript:ShowPickup(options)
	options = options or {}
	if self.held then return end
	
	print(recreated, self.properties.recreate)
	if not options.recreated and self.properties.recreate then
		print("Spawner was flying, re-creating")
		self:Remove({ force = true })
		local newThing = GetWorld():Spawn(self.properties.root:GetTemplate(), self.initPosition, self.initRotation)
		newThing:FindScript("pickupSpawnerScript", true):ShowPickup({ recreated = true })
	else
		self:SetVisibleAndCollision(true, true)

		if self.rotateTask then
			self:Cancel(self.rotateTask)
			self.rotateTask = nil
		end
		
		if self.respawnTask then
			self:Cancel(self.respawnTask)
			self.respawnTask = nil
		end

		if self.properties.rotateTime ~= 0 then
			self.rotateTask = self:Schedule(
				function()
					while true do
						Wait(Entity.AlterRotation(self.properties.root, Rotation.New(0, -180, 0), Rotation.New(0, 180, 0), self.properties.rotateTime))
					end
				end
			)
		end
		self.canPickup = true
	end
end

-- Hide the pickup
function PickupSpawnerScript:HidePickup()

	if self.held then return end

	self:SetVisibleAndCollision(false, false)
	
	if self.rotateTask then
		self:Cancel(self.rotateTask)
		self.rotateTask = nil
	end
	
	if self.respawnTask then
		self:Cancel(self.respawnTask)
		self.respawnTask = nil
	end

	self.canPickup = false
	
end

-- Hide the pickup and if respawning is true then spawn it in after a while
function PickupSpawnerScript:ShowPickupAfterRespawnDelay()

	if self.held then return end

	self:HidePickup()

	self.respawnTask = self:Schedule(
		function()
			print("Respawning soon", self.properties.spawnTimeMin, self.properties.spawnTimeMax)
			Wait(math.random(self.properties.spawnTimeMin, self.properties.spawnTimeMax))
			print("Respawning")
			self:ShowPickup()
			self.respawnTask = nil
		end
	)
	
end

function PickupSpawnerScript:CollectEntities(root, t)
	if self.entities then
		return self.entities
	else
		if not root then return t end
		
		table.insert(t, root)
		for _, childEntity in ipairs(root:GetChildren()) do
			self:CollectEntities(childEntity, t)
		end
		return t
	end
end

function PickupSpawnerScript:SetVisibleAndCollision(visible, collisionEnabled)
	-- collect this entity and any directly below is in the hierarchy (anything parented to us)
	local entities = self:CollectEntities(self.properties.root, {})
	
	-- turn off visibility and if its a mesh or voxel mesh then turn off collisionEnabled
	for _, entity in ipairs(entities) do
		-- setting enableCollisionOnChildren to false means we won't adjust collision on children
		if self.properties.enableCollisionOnChildren or entity == self.properties.root then
			if entity:IsA(Mesh) or entity:IsA(Voxels) then
				entity.collisionEnabled = collisionEnabled
			elseif entity:IsA(Trigger) then
				entity.active = collisionEnabled
			end
		end
		entity.visible = visible
	end
end

-- This function is called when a player interacts (E) with the entity in the game
function PickupSpawnerScript:OnInteract(player)
	if not self.properties.useOnCollision then
		self:Pickup(player)
	end
end

-- This function is called when a player collides with the entity in the game
function PickupSpawnerScript:OnCollision(player)
	if self.properties.useOnCollision then
		self:Pickup(player)
	end
end

function PickupSpawnerScript:OnTriggerEnter(player)
	if player and player:IsA(Character) and self.properties.useOnCollision then
		self:Pickup(player)
	end
end

function PickupSpawnerScript:GetPickupTemplate()
	-- if we have a pickup template (or we're using ourselves as a template)
	if self.properties.useSelfAsTemplate then
		if not self.properties.root then return nil end 
		return self.properties.root:GetTemplate()
	else
		return self.properties.pickupTemplate
	end
end

function PickupSpawnerScript:Remove(options)
	options = options or {}
	if self.properties.singlePickup or options.force then
		local entities = self:CollectEntities(self.properties.root, {})
		print("Destroying", #entities)
		for _, entity in pairs(entities) do
			entity:Destroy()
		end
	end
end

-- called when the player either interacts or collides with the entity and handles what happens
-- the outcome is controlled by the properties defined at the top of the script and controlled by the editor
function PickupSpawnerScript:Pickup(player)

	if not self.canPickup then
		return
	end
	
	if not player:IsAlive() then
		return
	end
	
	player:GetUser():SendToScripts("PlaySoundLocally",self.properties.pickupSound)
	player:SendToScripts("Collected")
	
	-- if the pickupTemplate has an inventoryItemSpecScript, then add it to the inventory	
	local pickupTemplate = self:GetPickupTemplate()
	if pickupTemplate and pickupTemplate:FindScriptProperties("inventoryItemSpecScript") then

		local inventoryScript = player:GetUser().inventoryScript

		if not inventoryScript then
			Print("Pickup: Not picking up as user has no inventory")
			return
		end
		if not inventoryScript:AddToInventory(pickupTemplate, 1, true) then
			return
		end

	end
	
	-- send a challenge event with either the picked up template or just the template
	-- this pickup is from as the name
	local challengeTemplate = pickupTemplate or self.properties.root:GetTemplate()
	player:GetUser():SendChallengeEvent("pickup", {name = challengeTemplate and challengeTemplate:GetName() or nil})
	
	-- if respawning is set then this will respawn it after a delay otherwise hide it
	if (self.properties.recreate or not self.properties.singlePickup) and self.properties.respawning then
		print("Will respawn later")
		self:ShowPickupAfterRespawnDelay()
	else
		self:HidePickup()
	end

	-- for things like health packs that use on pickup
	self.properties.onPickup:Send(player, self:GetEntity())	
	
	self:Remove()
end

return PickupSpawnerScript
