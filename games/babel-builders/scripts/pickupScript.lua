local PickupScript = {}

-- Script properties are defined here
PickupScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "requiredRole", type = "string", options = { "miner", "lumberjack" } },
	{ name = "resource", type = "string", options = { "wood", "stone" } },
	{ name = "heldRotation", type = "rotation" },
	{ name = "heldPosition", type = "vector" },
	{ name = "destroyTimer", type = "number", default = 600, tooltip = "in seconds" }
}

--This function is called on the server when this entity is created
function PickupScript:Init()
end

function PickupScript:ScheduleDestruction()
	self:Schedule(function()
		Wait(self.properties.destroyTimer)
		self:GetEntity():Destroy()
	end)
end

function PickupScript:GetInteractPrompt(prompts)
	prompts.interact = "Pickup " .. self.properties.resource 
end

function PickupScript:OnInteract(player, hitResult)
	player:SendToScripts("PickupResource", self:GetEntity())
end

return PickupScript