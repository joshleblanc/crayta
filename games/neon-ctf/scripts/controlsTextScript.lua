local ControlsTextScript = {}

-- Script properties are defined here
ControlsTextScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "text", type = "text" }
}

--This function is called on the server when this entity is created
function ControlsTextScript:ClientInit()
	self:GetEntity().controlsWidget.js.controls.text = self.properties.text
end

return ControlsTextScript
