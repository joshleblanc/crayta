local DestroyerTriggerScript = {}

-- Script properties are defined here
DestroyerTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function DestroyerTriggerScript:Init()
end

function DestroyerTriggerScript:OnTriggerEnter(other)
	if not other then return end -- how is this even possible
	
	local pickupScript = other:FindScript("pickupSpawnerScript", true)
	
	if pickupScript then
		pickupScript:Remove()
	elseif other:IsA(Mesh) then
		other:Destroy()
	end
end

return DestroyerTriggerScript
