local TeamResourcesScript = {}

-- Script properties are defined here
TeamResourcesScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "gameStorageController", type = "entity" }
}

function TeamResourcesScript:HandleStorageUpdate(key, value)
	local team = self:GetEntity():FindScriptProperty("team")
	if key == FormatString("{1}-wood", team) then
		self:UpdateWidget("wood", value)
	end
	
	if key == FormatString("{1}-stone", team) then
		self:UpdateWidget("stone", value)
	end
	
	if key == FormatString("{1}-gold", team) then
		self:UpdateWidget("gold", value)
	end
end

function TeamResourcesScript:LocalInit()
	self.widget = self:GetEntity().teamResourcesWidget
	
	local p = self.properties.gameStorageController.gameStorageControllerScript
	local team = self:GetEntity():FindScriptProperty("team")
	
	self.widget.js.data.wood = p:Get("{1}-wood", team)
	self.widget.js.data.stone = p:Get("{1}-stone", team)
	self.widget.js.data.gold = p:Get("{1}-gold", team)
end

function TeamResourcesScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToLocal("UpdateWidget", key, value)
		return
	end
	
	self.widget.js.data[key] = value
end

return TeamResourcesScript
