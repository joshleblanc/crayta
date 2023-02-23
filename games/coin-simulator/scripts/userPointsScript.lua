local UserPointsScript = {}

-- Script properties are defined here
UserPointsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserPointsScript:Init()
	self.data = self:GetSaveData()
	if not self.data.initialized then
		self.data.points = 0
		self.data.initialized = true
		self:SetSaveData(self.data)
	end
	
	self:UpdateWidget("points", self.data.points)
end

function UserPointsScript:LocalInit()
	self.widget = self:GetEntity().userPointsWidget
end

function UserPointsScript:Add(amt)
	if not IsServer() then
		self:SendToServer("Add", amt)
		return
	end
	
	self.data.points = self.data.points + amt
	self:SetSaveData(self.data)
	self:UpdateWidget("points", self.data.points)
end

function UserPointsScript:CanAfford(amt)
	return self.data.points >= amt
end

function UserPointsScript:Remove(amt)
	if not IsServer() then
		self:SendToServer("Remove", amt)
		return
	end
	
	self.data.points = self.data.points - amt
	self:SetSaveData(self.data)
	self:UpdateWidget("points", self.data.points)
end


function UserPointsScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToLocal("UpdateWidget", key, value)
		return
	end
	
	self.widget.js.data[key] = value
end

return UserPointsScript
