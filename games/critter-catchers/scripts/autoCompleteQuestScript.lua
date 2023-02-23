local AutoCompleteQuestScript = {}

-- Script properties are defined here
AutoCompleteQuestScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onComplete", type = "event" },
}

--This function is called on the server when this entity is created
function AutoCompleteQuestScript:Init()
	self:Schedule(function()
		Wait(5)
		self.properties.onComplete:Send()
	end)
end

return AutoCompleteQuestScript
