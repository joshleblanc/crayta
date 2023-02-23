local EntityCacheScript = {}

-- Script properties are defined here
EntityCacheScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function EntityCacheScript:Init()
	self:PopulateCache()
end

function EntityCacheScript:ClientInit()
	self:PopulateCache()
end

function EntityCacheScript:PopulateCache(root)
	self.cache = self.cache or {}
	root = root or self:GetEntity()
	
	local children = root:GetChildren()
	for _, child in ipairs(children) do 
		local template = child:GetTemplate()
		if template then 
			self.cache[template:GetName()] = child
		else
			self:PopulateCache(child)
		end
	end
end

--This function is called on the server when this entity is created
function EntityCacheScript:FindEntityByTemplate(templateName)
	local key = templateName
	if templateName.GetName then 
		key = templateName:GetName()
	end
	
	return self.cache[key]
end

return EntityCacheScript
