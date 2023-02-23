local BaseRoomScript = {}

-- Script properties are defined here
BaseRoomScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "id", type = "string" },
	{ name = "name", type = "text" },
	{ name = "unpurchasedTemplate", type = "template" },
	{ name = "defaultTemplate", type = "template" }
}

--This function is called on the server when this entity is created
function BaseRoomScript:Init()
end

function BaseRoomScript:SetChild(child)
	self.child = child
end

function BaseRoomScript:GetChild()
	return self.child
end



return BaseRoomScript
