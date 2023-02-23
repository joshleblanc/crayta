local UserSaveDataScript = {}

-- Script properties are defined here
UserSaveDataScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserSaveDataScript:Init()
	self.data = self:GetSaveData()
end

function UserSaveDataScript:Get(key)
	return self.data[key]
end

function UserSaveDataScript:Set(key, value)
	if not IsServer() then
		self:SendToServer("Set", key, value)
		return
	end
	
	self.data[key] = value
	self:SetSaveData(self.data)
end

return UserSaveDataScript
