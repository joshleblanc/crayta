local MagnetLocatorScript = {}

-- Script properties are defined here
MagnetLocatorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "magnet", type = "entity" }
}

--This function is called on the server when this entity is created
function MagnetLocatorScript:LocalInit()
	self.widget = self:GetEntity().magnetLocatorWidget
end

function MagnetLocatorScript:LocalOnTick()
	if not self.properties.magnet then return end 
	
	local pos = self:GetEntity():ProjectPositionToScreen(self.properties.magnet:GetPosition())
	local target = self.properties.magnet:GetParent():FindScriptProperty("target")
	if pos then
		self.widget:CallFunction("setViewportPoint", pos.x, pos.y)
	end
	if target then
		self.widget.js.data.color = target:FindScriptProperty("color")
	else	
		self.widget.js.data.color = "black"
	end
end

return MagnetLocatorScript
