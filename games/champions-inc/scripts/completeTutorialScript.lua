local CompleteTutorialScript = {}

-- Script properties are defined here
CompleteTutorialScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "tutorialStepIds", type = "string", container = "array" },
	{ name = "activateTutorialStepIds", type = "string", container = "array" }
}

--This function is called on the server when this entity is created
function CompleteTutorialScript:Init()
end

function CompleteTutorialScript:CompleteTutorialStep(user)
	user.documentStoresScript:UseDb("tutorials", function(db)
		for i=1,#self.properties.tutorialStepIds do 
			db:UpdateOne({ _id = self.properties.tutorialStepIds[i] }, {
				completed = true
			})
			print("Completing", self.properties.tutorialStepIds[i])
			GetWorld():BroadcastToScripts("OnTutorialComplete", user, self.properties.tutorialStepIds[i])
		end
		
		for i=1,#self.properties.activateTutorialStepIds do 
			db:InsertOne({ 
				_id = self.properties.activateTutorialStepIds[i],
				completed = false
			})
			print("Activating", self.properties.activateTutorialStepIds[i])
			GetWorld():BroadcastToScripts("OnTutorialActivate", user, self.properties.activateTutorialStepIds[i])
		end
	end)
end

return CompleteTutorialScript
