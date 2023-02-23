
local RoomScript = {}

-- Script properties are defined here
RoomScript.Properties = {
	-- Example property
	{ name = "locationTrigger", type = "entity" },
	{ name = "owner", type = "entity", editable = false },
	{ name = "decorations", type = "entity" },
	{ name = "onCheckin", type = "event" },
	{ name = "onCheckout", type = "event" },
	{ name = "sign", type = "entity" },
}

--This function is called on the server when this entity is created
function RoomScript:Init()
	self.decorations = self.properties.decorations:GetChildren()
end

function RoomScript:Checkin(user)
	self.properties.owner = user
	local username = tostring(user:GetUsername())
	local title = Text.Format("{1}'s room", username)
	
	self.properties.locationTrigger.showLocationScript.properties.label = title
	self.properties.sign.simpleSignScript.properties.title = user:GetUsername()
	self:Schedule(function()
		Wait(1)
		self.properties.sign.simpleSignScript:SendToAllClients("UpdateSign")
	end)
	
	user:SendToScripts("DoOnLocal", self:GetEntity(), "SetTitle", "&#xf015;")
	
	self:ForEachDecoration(function(deco)
		print("Checking if user owns" , deco:FindScriptProperty("id"), user.saveDataScript:GetData("loot-box-{1}", deco:FindScriptProperty("id")))
		if user.saveDataScript:GetData("loot-box-{1}", deco:FindScriptProperty("id")) then
			deco:SendToScripts("SetVisibilityOn")
			deco:SendToScripts("SetCollisionOn")
		else
			deco:SendToScripts("SetVisibilityOff")
			deco:SendToScripts("SetCollisionOff")
		end
	end)
	
	print("Sending onCheckin")
	self.properties.onCheckin:Send(user)
end

function RoomScript:SetTitle(val)
	self.properties.locationTrigger.showLocationScript.properties.title = Text.Format(val);
end

function RoomScript:Owns(user, id)
	return user.saveDataScript:GetData("loot-box-{1}", id)
end

function RoomScript:ForEachDecoration(fn)
	for _, deco in ipairs(self.decorations) do
		fn(deco)
	end
end

function RoomScript:ShowUnlock(id)
	print("Showing unlock", id)
	local deco = self:FindDeco(id)
	print("Found deco", deco)
	if not deco then return end 
	
	deco:SendToScripts("SetVisibilityOn")
	deco:SendToScripts("SetCollisionOn")
end

function RoomScript:FindDeco(id)
	for _, deco in ipairs(self.decorations) do
		if deco:FindScriptProperty("id") == id then
			return deco
		end
	end
end

function RoomScript:OnUserLogout(user)
	if user == self.properties.owner then
		self:Checkout()
	end
end

function RoomScript:Checkout()
	self.properties.owner = nil
	self.properties.locationTrigger.showLocationScript.properties.title = Text.Format("")
	self.properties.sign.simpleSignScript.properties.title = Text.Format("")
	
	self:Schedule(function()
		Wait(1)
		self.properties.sign.simpleSignScript:SendToAllClients("UpdateSign")
	end)
	
	self:ForEachDecoration(function(deco)
		deco:SendToScripts("SetVisibilityOff")
		deco:SendToScripts("SetCollisionOff")
	end)
	
	self.properties.onCheckout:Send()
end

function RoomScript:HasOwner()
	return self.properties.owner ~= nil
end

return RoomScript
