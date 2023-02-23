local InvisibleScript = {}

-- Script properties are defined here
InvisibleScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function InvisibleScript:Init()
	local children = self:GetEntity():GetChildren()
	for i=1,#children do
		children[i].visible = false
	end
end

return InvisibleScript
