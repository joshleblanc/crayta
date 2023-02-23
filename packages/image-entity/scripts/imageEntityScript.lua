local ImageEntityScript = {}

-- Script properties are defined here
ImageEntityScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ImageEntityScript:Init()
	local w = self:GetEntity().imageEntityWidget
	
	w.properties.image = self:GetImage()
end

function ImageEntityScript:GetImage()
	local template = self:GetEntity():GetParent():GetTemplate()
	print(template:GetName())
	if not template then
		return ""
	end
		
	local iconProperty = template:FindScriptProperty("iconUrl")
	
	if iconProperty and #iconProperty > 0 then 
		return iconProperty
	end
	
	local iconAsset = template:FindScriptProperty("iconAsset")
		
	if iconAsset then
		return iconAsset:GetIcon()
	else 
		return ""
	end
end



return ImageEntityScript
