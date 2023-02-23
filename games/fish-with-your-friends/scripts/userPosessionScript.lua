local UserPosessionScript = {}

-- Script properties are defined here
UserPosessionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" },
	{ name = "name", type = "text" },
	{ name = "defaultTemplate", type = "template" },
	{ name = "equipOnInit", type = "boolean" },
	{ name = "equipGrip", type = "gripasset" }
}

--This function is called on the server when this entity is created
function UserPosessionScript:Init()
	self.db = self:GetEntity().documentStoresScript
	
	self:Schedule(function()
		self.db:WaitForData()
		
		local templateName = self.properties.defaultTemplate:GetName()
		
		local data = self:AddToOwned(templateName)
		
		if not data[self:ActiveId()] then 	
			self:SetActive(templateName)
		end
	end)
end

-- character_pelvis, character_torso, character_leftfoot, character_rightfoot, character_lefthand, character_righthand, character_head, character_leftgrip, character_rightgrip
-- called via playerPosessionsScript
function UserPosessionScript:HandlePlayerSpawn(player)
	if self.properties.equipOnInit then 
		print("Equipping Posession")
		self.possession = GetWorld():Spawn(self:ActiveTemplate(), Vector.Zero, Rotation.Zero)
		self.possession:AttachTo(self:GetEntity():GetPlayer(), "character_righthand")
		self:GetEntity():GetPlayer():SetGrip(self.properties.equipGrip)
	end
end

function UserPosessionScript:ActiveId()
	return FormatString("active_{1}", self.properties.id)
end

function UserPosessionScript:AddToOwned(templateName)
	local arrName = FormatString("owned_{1}", self.properties.id)
	local payload = {
		_addToSet = {}
	}
	
	payload["_addToSet"][arrName] = templateName
	return self.db:UpdateOne({}, payload, { upsert = true })
end

function UserPosessionScript:SetActive(templateName)
	local payload = {
		_set = {}
	}
	payload["_set"][self:ActiveId()] = templateName
	
	return self.db:UpdateOne({}, payload)
end

function UserPosessionScript:ActivePosession()
	local key = FormatString("active_{1}", self.properties.id)
	return self.db:FindOne()[self:ActiveId()]
end

function UserPosessionScript:ActiveTemplate()
	local activeId = self:ActivePosession()
	local activeTemplate = Template.Find(activeId)
	
	return activeTemplate
end

function UserPosessionScript:GetFishingPower()
	local activeTemplate = self:ActiveTemplate()
	return activeTemplate:FindScriptProperty("fishingPower") or 0
end

return UserPosessionScript
