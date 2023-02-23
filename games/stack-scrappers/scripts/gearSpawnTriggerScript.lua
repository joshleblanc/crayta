local GearSpawnTriggerScript = {}

-- Script properties are defined here
GearSpawnTriggerScript.Properties = {
	-- Example property
	{ name = "gearTemplate", type = "template" },
	{ name = "gearThrowLocation", type = "entity", is = "Locator" }
}

function GearSpawnTriggerScript:OnTriggerEnter(entity)
	if not entity then return end -- how is this even possible
	local user = entity:FindScriptProperty("user")
	if not user then return end 
	
	local numGears = user:FindScriptProperty("score")
	print("Spawning " .. numGears .. "gears")
	user:SendToScripts("ResetScore")
	
	self:Schedule(function()
		for i=1,numGears do
			local newGear = GetWorld():Spawn(self.properties.gearTemplate, self.properties.gearThrowLocation)

			local script = newGear:FindScript("pickupSpawnerScript", true)
			script:ShowPickup()
			script.properties.singlePickup = true
					
			newGear:SendToScripts("Fly")
			Wait()
		end
	end)
end

return GearSpawnTriggerScript
