local DropoffQuestCompletionQuestScript = {}

-- Script properties are defined here
DropoffQuestCompletionQuestScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "thingToEquip", type = "template" },
	{ name = "onComplete", type = "event" },
}

--This function is called on the server when this entity is created
function DropoffQuestCompletionQuestScript:Init()
end

function DropoffQuestCompletionQuestScript:HandleDropoff(user)
	if user ~= self:GetEntity() then return end 
	
	self.properties.onComplete:Send()
	
	local thing = GetWorld():Spawn(self.properties.thingToEquip, Vector.Zero, Rotation.Zero)
	thing:SendToScripts("Equip", user, thing)
end

return DropoffQuestCompletionQuestScript
