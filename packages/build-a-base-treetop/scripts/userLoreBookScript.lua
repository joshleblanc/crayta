local UserLoreBookScript = {}

-- Script properties are defined here
UserLoreBookScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "instructions", type = "text" },
	{ name = "closeSound", type = "soundasset" },
	{ name = "debug", type = "boolean", default = false, tooltip = "Ignore save data" }
}

--This function is called on the server when this entity is created
function UserLoreBookScript:Init()
	if self.properties.debug then
		self.data = {}
	else
		self.data = self:GetSaveData()
	end
	
	self:SendToLocal("ClientSetData", self.data)
end

function UserLoreBookScript:LocalInit()	
	self.open = false
	self.widget = self:GetEntity().userLoreBookWidget
	self.widget.js.data.instructions = self.properties.instructions
	self.widget.js.data.closing = true
	self.widget:Hide()
end

function UserLoreBookScript:ServerSetData(data)
	self.data = data
	self:SetSaveData(data)
end

function UserLoreBookScript:ClientSetData(data)
	print("Setting data on client")
	self.data = data
end

function UserLoreBookScript:IsReady()
	return self.data
end

function UserLoreBookScript:SetData(data)
	if IsServer() then
		self:ServerSetData(data)
		self:SendToLocal("ClientSetData", data)
	else
		self:ClientSetData(data)
		self:SendToServer("ServerSetData", data)	
	end
end

function UserLoreBookScript:CanRead(id)
	local day = self:GetDay()
	return self.data[id] == nil or day > self.data[id]
end

function UserLoreBookScript:GetDay()
	return math.floor(GetWorld():GetUTCTime() / 86400)
end

function UserLoreBookScript:OpenLoreBook(id, header, body, daily)
	if IsServer() then
		-- only run the find-lore-book event once per day, per book
		if not daily or self:CanRead(id) then
			self.data[id] = self:GetDay()
			self:SetData(self.data)
			self:GetEntity():SendXPEvent("find-lore-book")
		end
		self:SendToLocal("OpenLoreBook", id, header, body, daily)
		return
	end
	
	self:GetEntity():GetPlayer():SetInputLocked(true)
	self.widget.js.data.header = header
	self.widget.js.data.closing = false
	self.widget:CallFunction("AddText", body)
	self.widget:Show()
	self.open = true
end

function UserLoreBookScript:CloseLoreBook()
	self:Schedule(function()
		if self.open then
			self:GetEntity():PlaySound2D(self.properties.closeSound)
			self.widget.js.data.closing = true
			Wait(.5)
			self.widget:Hide()
			self:GetEntity():GetPlayer():SetInputLocked(false)
			self.open = false
		end
	end)	
end

function UserLoreBookScript:LocalOnButtonPressed(btn)
	if not self.open then return end 
	
	if btn == "extra1" then
		self:CloseLoreBook()
	end
end

return UserLoreBookScript
