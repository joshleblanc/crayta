local CMenuQuestsTrackerScript = {}

-- Script properties are defined here
CMenuQuestsTrackerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function CMenuQuestsTrackerScript:Init()
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	self.user.userQuestsScript.properties.onQuestProgress:Listen(self, "UpdateTracker")
end

--This function is called on the server when this entity is created
function CMenuQuestsTrackerScript:LocalInit()
	if self:GetEntity():IsA(User) then
		self.user = self:GetEntity()
	else 
		self.user = self:GetEntity():GetUser()
	end
	
	self.widget = self:GetEntity().cMenuQuestsTrackerWidget

	self:Schedule(function()
		while true do 
			Wait(1)
			self:UpdateTracker()
		end
	end)
	
end

function CMenuQuestsTrackerScript:UpdateTracker()
	if IsServer() then 
		self:SendToLocal("UpdateTracker")
		return
	end

	local trackedQuests = self.user.userQuestsScript:GetTrackedQuests() 
	
	local data = {}
	
	for _, quest in ipairs(trackedQuests) do 
		table.insert(data, {
			id = quest.properties.id,
			name = quest.properties.name,
			progress = FormatString("{1}%", math.floor(quest:Progress() * 100))
		})
	end
	
	self.widget.js.data.quests = data
end

return CMenuQuestsTrackerScript
