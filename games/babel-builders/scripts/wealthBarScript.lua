local WealthBarScript = {}

-- Script properties are defined here
WealthBarScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "totalRequired", type = "number" },
	{ name = "gameStorageController", type = "entity" }
}

function WealthBarScript:HandleStorageUpdate(key, value)
	local teams = { 1, 2 }
	local resources = { "gold", "wood", "stone" }
	for _, team in ipairs(teams) do
		for _, resource in ipairs(resources) do
			if key == FormatString("{1}-{2}", team, resource) then
				self:UpdateWidget(FormatString("team{1}{2}", team, resource), value)
				self:CallFunction("update")
			end
		end
	end
end

function WealthBarScript:CallFunction(fn)
	if IsServer() then
		self:SendToLocal("CallFunction", fn)
		return
	end
	
	self.widget:CallFunction(fn)
end

function WealthBarScript:LocalInit()
	self.widget = self:GetEntity().wealthBarWidget
	self.widget.js.data.totalRequired = self.properties.totalRequired
	
	local teams = { 1, 2 }
	local resources = { "gold", "wood", "stone" }
	local p = self.properties.gameStorageController.gameStorageControllerScript
	for _, team in ipairs(teams) do
		for _, resource in ipairs(resources) do
			self.widget.js.data[FormatString("team{1}{2}", team, resource)] = p:Get("{1}-{2}", team, resource)
		end
	end
	self.widget:CallFunction("update")
end

function WealthBarScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToLocal("UpdateWidget", key, value)
		return
	end
	
	self.widget.js.data[key] = value
end

return WealthBarScript
