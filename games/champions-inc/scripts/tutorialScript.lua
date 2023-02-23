local TutorialScript = {}

-- Script properties are defined here
TutorialScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "tutorialStepId", type = "string" },
	{ name = "firstStep", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function TutorialScript:ClientInit()
	local user = GetWorld():GetLocalUser()
	
	self.widget = self:GetEntity().tutorialWidget
	
	user.documentStoresScript:UseDb("tutorials", function(db)
		local doc = db:FindOne({ _id = self.properties.tutorialStepId })
		if self.properties.firstStep then 
			if not doc then 
				doc = db:InsertOne({
					_id = self.properties.tutorialStepId,
					completed = false
				})
			end
		end
		
		if not doc or doc.completed then 
			self.widget:Hide()
		elseif not doc.completed then 
			self.widget:Show()
		end
	end)
end

function TutorialScript:OnTutorialComplete(user, tutorialId)
	print("Handling tutorial complete", tutorialId)
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "OnTutorialComplete", user, tutorialId)
		return
	end
	
	if self.properties.tutorialStepId == tutorialId then 
		self.widget:Hide()
	end
	
end

function TutorialScript:OnTutorialActivate(user, tutorialId)
	if IsServer() then 
		user:SendToScripts("DoOnLocal", self:GetEntity(), "OnTutorialActivate", user, tutorialId)
		return
	end
	
	if self.properties.tutorialStepId == tutorialId then 
		self.widget:Show()
	end
end

return TutorialScript
