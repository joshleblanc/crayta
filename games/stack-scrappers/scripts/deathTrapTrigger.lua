local DeathTrapTrigger = {}

-- Script properties are defined here
DeathTrapTrigger.Properties = {
	-- Example property
	{name = "decoy", type = "template"},	
}

--This function is called on the server when this entity is created
function DeathTrapTrigger:Init()
end

function DeathTrapTrigger:OnTriggerEnter(decoy)
	if decoy:IsA(mesh) and decoy:GetTemplate(self.properties.decoy) then
		decoy:SendToScripts("GrindUp")	
	end	
end


return DeathTrapTrigger
