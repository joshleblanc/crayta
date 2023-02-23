local SetScript = {}

-- Script properties are defined here
SetScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "arena", type = "entity" },
	{ name = "blocks", type = "entity" },
	{ name = "id", type = "string" },
	{ name = "name", type = "text" },
	{ name = "defaultSelected", type = "boolean", default = false },
	{ name = "imageUrl", type = "string" },
	{ name = "unlockLevel", type = "number", default = 0 },
}

--This function is called on the server when this entity is created
function SetScript:Init()
	local initialized = self:GetEntity().saveDataScript:GetData(FormatString("set-{1}-initialized", self.properties.id))
	if not initialized then
		self:GetEntity():SendToScripts("SaveData", FormatString("set-{1}-initialized", self.properties.id), true)
		self:GetEntity():SendToScripts("SaveData", FormatString("set-{1}-selected", self.properties.id), self.properties.defaultSelected)
	end
	
	print(self.properties.id, self:IsSelected())
end

function SetScript:SelectSet()
	print("Selecting", self.properties.id)
	self:GetEntity().saveDataScript:SaveData(FormatString("set-{1}-selected", self.properties.id), true)
end

function SetScript:DeselectSet()
	print("Deselecting", self.properties.id)
	self:GetEntity().saveDataScript:SaveData(FormatString("set-{1}-selected", self.properties.id), false)
end

function SetScript:IsSelected()
	return self:GetEntity().saveDataScript:GetData(FormatString("set-{1}-selected", self.properties.id))
end

function SetScript:ToTable() 
	return {
		id = self.properties.id,
		name = self.properties.name,
		imageUrl = self.properties.imageUrl,
		unlocked = self:GetEntity().userStatScript:Level() >= self.properties.unlockLevel,
		selected = self:IsSelected(),
		unlockLevel = self.properties.unlockLevel,
		unlockedAt = FormatString("Level {1}", self.properties.unlockLevel)
	}
end

return SetScript
