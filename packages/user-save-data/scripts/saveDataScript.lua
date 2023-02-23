local SaveDataScript = {}

-- Script properties are defined here
SaveDataScript.Properties = {
	{ name = "reset", type = "boolean", default = false, tooltip = "If this is checked, save data will be reset on preview" },
	{ name = "onSaveDataReady", type = "event" }
}

function SaveDataScript:Init()
	if self.properties.reset then
		self:SetData({})
	else
		self:SetData(self:GetSaveData())
	end
	
	self:Schedule(function()
		self:WaitForData()
		self.properties.onSaveDataReady:Send(self:GetEntity())
	end)
end

function SaveDataScript:LocalInit()
	self:Schedule(function()
		self:WaitForData()
		self.properties.onSaveDataReady:Send(self:GetEntity())
	end)
end

function SaveDataScript:TryWaitForData()
	if not IsInSchedule() then return end 
	
	self:WaitForData()
end

function SaveDataScript:WaitForData()
	while not self.data do
		Wait()
	end
end

function SaveDataScript:LocalSetData(data)
	self.data = data
end

function SaveDataScript:ServerSetData(data)
	self.data = data
	self:SetSaveData(data)
end

function SaveDataScript:SetData(data)
	if IsServer() then
		self:ServerSetData(data)
		self:SendToLocal("LocalSetData", data)
	else
		self:LocalSetData(data)
		self:SendToServer("ServerSetData", data)	
	end
end

function SaveDataScript:SaveData(key, value)
	self:TryWaitForData()
	
	printf("Saving {1} with {2}", key, value)
	self.data[key] = value
	self:SetData(self.data)
end

function SaveDataScript:GetData(...)
	self:TryWaitForData()
	
	if self.data then
		return self.data[FormatString(...)]
	end
end

return SaveDataScript
