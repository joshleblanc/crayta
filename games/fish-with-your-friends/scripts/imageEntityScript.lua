local ImageEntityScript = {}

-- Script properties are defined here
ImageEntityScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ImageEntityScript:Init()
	local w = self:GetEntity().imageEntityWidget
	w.properties.image = self:GetEntity():GetParent():FindScriptProperty("image")
end

return ImageEntityScript
