local ResourceStackScript = {}

-- Script properties are defined here
ResourceStackScript.Properties = {
	-- Example property
	{ name = "layers", type = "entity", container = "array" }
}

--This function is called on the server when this entity is created
function ResourceStackScript:Init()
	self:HideAll()
end

function ResourceStackScript:HideAll()
	for i=1,#self.properties.layers do
		self:HideEntity(self.properties.layers[i])
	end
end

function ResourceStackScript:Show(layer)
	self:HideAll()
	for i=1,layer do
		self:ShowEntity(self.properties.layers[i])
	end
end

function ResourceStackScript:ShowEntity(root)
	root.visible = true
	if root.collisionEnabled ~= nil then
		root.collisionEnabled = true
	end
	
	local children = root:GetChildren()
	for i=1,#children do
		self:ShowEntity(children[i])
	end
end


function ResourceStackScript:HideEntity(root)
	root.visible = false
	if root.collisionEnabled ~= nil then
		root.collisionEnabled = false
	end
	local children = root:GetChildren()
	for i=1,#children do
		self:HideEntity(children[i])
	end
end

function ResourceStackScript:NumLayers()
	return #self.properties.layers
end

return ResourceStackScript
