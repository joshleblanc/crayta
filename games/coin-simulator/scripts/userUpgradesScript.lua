local UserUpgradeScript = {}

-- Script properties are defined here
UserUpgradeScript.Properties = {
	-- Example property
	{ name = "invalidSound", type = "soundasset" },
	{ name = "confirmSound", type = "soundasset" },
	{ name = "close", type = "text" }
}

--This function is called on the server when this entity is created
function UserUpgradeScript:Init()
	self.data = self:GetSaveData()
	if not self.data.initialized then
		self.data.speed = 1
		self.data.jump = 1

		self.data.initialized = true
		self:SetSaveData(self.data)
	end
	
	self:UpdateWidget("jump", self.data.jump)
	self:UpdateWidget("speed", self.data.speed)
end

function UserUpgradeScript:Calc(n)
	return 10 - (10 * math.pow(2.71828182846, -0.000015 * n))
end

function UserUpgradeScript:Assign()
	if not IsServer() then 
		self:SendToServer("Assign")
		return
	end
	
	self:GetEntity():GetPlayer().speedMultiplier = 1 + self:Calc(self.data.speed)
	self:GetEntity():GetPlayer().jumpHeightMultiplier = 1 + self:Calc(self.data.jump)
	
	self:UpdateWidget("speedMultiplier", self:GetEntity():GetPlayer().speedMultiplier)
	self:UpdateWidget("jumpMultiplier", self:GetEntity():GetPlayer().jumpHeightMultiplier)
end

function UserUpgradeScript:LocalInit()
	self.widget = self:GetEntity().userUpgradeWidget
	self.widget.js.data.close = self.properties.close
end
	
function UserUpgradeScript:Show()
	if IsServer() then
		self:SendToLocal("Show")
		return
	end
	
	self.widget:Show()
end

function UserUpgradeScript:PlaySound(sound)
	if IsServer() then
		self:SendToLocal("PlaySound", sound)
		return
	end
	
	self:GetEntity():PlaySound2D(sound)
end



function UserUpgradeScript:Upgrade(what, amt) 
	if not IsServer() then 
		self:SendToServer("Upgrade", what, amt)
		return
	end
	
	if self:GetEntity().userPointsScript:CanAfford(amt) then
		self:GetEntity().userPointsScript:Remove(amt)
		self.data[what] = self.data[what] + amt
		self:SetSaveData(self.data)
		
		self:UpdateWidget(what, self.data[what])
		
		self:PlaySound(self.properties.confirmSound)
		self:Assign()
		self:GetEntity():SetLeaderboardValue(what, self.data[what])
	else
		self:PlaySound(self.properties.invalidSound)
	end	

end

function UserUpgradeScript:UpgradeAll(what)
	if not IsServer() then
		self:SendToServer("UpgradeAll", what)
		return
	end
	
	local amt = self:GetEntity().userPointsScript.data.points
	self:Upgrade(what, amt)
end

function UserUpgradeScript:Close()
	if IsServer() then
		self:SendToLocal("Close")
		return
	end
	
	self:Schedule(function()
		Wait()
		self.widget:Hide()
	end)
	
end

function UserUpgradeScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToLocal("UpdateWidget", key, value)
		return
	end
	
	self.widget.js.data[key] = value
end

return UserUpgradeScript
