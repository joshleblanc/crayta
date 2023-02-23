local PlayerRoleScript = {}

-- Script properties are defined here
PlayerRoleScript.Properties = {
	-- Example property
	{ name = "role", type = "string", editable = false },
	{ name = "equipment", type = "entity", editable = false },
	{ name = "holding", type = "entity", editable = false },
	{ name = "holdingResourceGrip", type = "gripasset" },
	{ name = "gameStorageController", type = "entity" }
}

PlayerRoleScript.Roles = {
	miner = {
		role = "miner",
		resource = "Stone"
	},
	lumberjack = {
		role = "lumberjack",
		resource = "Lumber"
	}
}

function PlayerRoleScript:Init()
	self.primaryDown = false
	self.swinging = false
	self.swingDamagedSomething = false
end

function PlayerRoleScript:SetRole(role, equipment)
	if self.properties.equipment then
		self.properties.equipment:Destroy()
	end
	self.properties.role = role
	self.properties.equipment = equipment
end

function PlayerRoleScript:OnTick()
	local thing, hitResult = self:GetEntity():GetInteraction()
	self:TryHarvest(thing, hitResult)
end

function PlayerRoleScript:TryHarvest(thing, hitResult)
	if not thing then return end
	if not self.primaryDown then return end 
	if self.swingDamagedSomething then return end
	if not thing:FindScriptProperty("isHarvestable") then return end 
	if thing:FindScriptProperty("requiredRole") ~= self.properties.role then return end 
	

	local distance = Vector.Distance(self:GetEntity():GetPosition(), thing:GetPosition())
	print(distance)
	if distance > 300 then return end
	
	self.swingDamagedSomething = true
	thing:ApplyDamage(self:GetEntity():GetUser():FindScriptProperty("strength"), hitResult, Vector.Zero, self:GetEntity())
end

function PlayerRoleScript:HasRole()
	return string.len(self.properties.role) > 0
end

function PlayerRoleScript:OnButtonPressed(btn)

	print(btn, self.properties.role, self.swinging, self.primaryDown, self.swingDamagedSomething)
	-- if not in a role then do nothing
	if not self:HasRole() then
		return
	end
	
	if self.properties.holding then
		return
	end
	
	if btn == "primary" then
		if self.swinging then return end 
		
		self.primaryDown = true
		self:Swing()
	end
end

function PlayerRoleScript:Swing()
	self.swinging = true
	self.swingDamagedSomething = false
	self:GetEntity():PlayAction("Melee", {
		events = {
			MeleeImpact = function()
				self.swinging = false
				if self.primaryDown then
					self:Swing()
				end	
			end
		}
	})
end

function PlayerRoleScript:OnButtonReleased(btn)
	if not self:HasRole() then
		return
	end
	
	if btn == "primary" then
		self.primaryDown = false
		self.swingDamagedSomething = false
	end
	
end

function PlayerRoleScript:PickupResource(thing)
	if self.properties.holding ~= nil then
		return
	end
	
	local newThing = GetWorld():Spawn(thing:GetTemplate(), Vector.Zero, Rotation.Zero)
	newThing.collisionEnabled = false
	self.properties.holding = newThing
	
	thing:Destroy()
	
	newThing:AttachTo(self:GetEntity(), "weapon_l")

	newThing:SetRelativeRotation(newThing:FindScriptProperty("heldRotation"))
	newThing:SetRelativePosition(newThing:GetRelativePosition() + newThing:FindScriptProperty("heldPosition"))
	if self.properties.equipment then
		self.properties.equipment.visible = false
	end

	self:GetEntity():SetGrip(self.properties.holdingResourceGrip)
	
	self:GetEntity():GetUser():SendXPEvent("resource", { action = "pickup" })
end

function PlayerRoleScript:RemoveResource()
	if not self.properties.holding then return end
	
	self.properties.holding:Destroy()
	
	if self.properties.equipment then
		self.properties.equipment.visible = true
		self:GetEntity():SetGrip(self.properties.equipment:FindScriptProperty("grip"))
	else
		self:GetEntity():SetNoGrip()
	end
end

function PlayerRoleScript:DropoffResource(resource,cart)
	if not self.properties.holding then return end
	if resource ~= self.properties.holding:FindScriptProperty("resource") then 
		self:GetEntity():GetUser():SendToScripts("Shout", FormatString("This is the {1} dropoff!", resource))
		return
	end 
	
	self:RemoveResource()
	
	if not cart then
		local team = self:GetEntity():GetUser():FindScriptProperty("team")
		self.properties.gameStorageController:SendToScripts("Update", FormatString("{1}-{2}", team, resource), 1)
		self:GetEntity():GetUser():AddToLeaderboardValue(FormatString("{1}-collected", resource), 1)
		self:GetEntity():GetUser():SendToScripts("ProgressQuest", resource)
		self:GetEntity():GetUser():SendXPEvent("resource", { action = "dropoff" })
		self:GetEntity():GetUser().userWealthScript:Add(1)
	end
end

return PlayerRoleScript
