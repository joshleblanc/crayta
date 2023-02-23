local HeroAquisitionQuestCompletionScript = {}

-- Script properties are defined here
HeroAquisitionQuestCompletionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "hero", type = "template" },
	{ name = "onComplete", type = "event" },
}

--This function is called on the server when this entity is created
function HeroAquisitionQuestCompletionScript:Init()
end

function HeroAquisitionQuestCompletionScript:OnMyRecordInserted(t, record)
	if t ~= "heroes" then return end 
	
	local template = GetWorld():FindTemplate(record.templateName)
	if template == self.properties.hero then 
		self.properties.onComplete:Send()
	end
end

function HeroAquisitionQuestCompletionScript:HandleRetroactiveHeroAquisition(template)
	print("handling retroactive hero acquisition", template:GetName(), self.properties.hero:GetName())
	if template == self.properties.hero then 
		self.properties.onComplete:Send()
	end
end

return HeroAquisitionQuestCompletionScript
