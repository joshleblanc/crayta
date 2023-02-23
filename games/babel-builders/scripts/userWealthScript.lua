local UserWealthScript = {}

-- Script properties are defined here
UserWealthScript.Properties = {
	-- Example property
	{ name = "gameStorageController", type = "entity" }
}

--This function is called on the server when this entity is created
function UserWealthScript:Init()
	self.data = self:GetSaveData()
	if not self.data.initialized then
		local team = self:GetEntity():FindScriptProperty("team")
		local total = 0
		
		self:GetEntity():GetLeaderboardValue("wood-collected", function(score)
			self:Add(score)
		end)
		
		self:GetEntity():GetLeaderboardValue("stone-collected", function(score)
			self:Add(score)
		end)
		
		self:GetEntity():GetLeaderboardValue("gold-earned", function(score)
			self:Add(score)
		end)
		self.data.initialized = true
		self:SetSaveData(self.data)
	end
end

function UserWealthScript:Add(amt)
	local team = self:GetEntity():FindScriptProperty("team")
	self:GetEntity():AddToLeaderboardValue(FormatString("{1}-wealth", team), 1)
end

return UserWealthScript
