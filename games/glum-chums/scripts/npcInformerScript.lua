local NpcInformerScript = {}

-- Script properties are defined here
NpcInformerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "entity", type = "entity" },
	{ name = "script", type = "scriptasset" },
	{ name = "propertyToSet", type = "string" },
}

--This function is called on the server when this entity is created
function NpcInformerScript:Init()
	self.properties.entity:FindScript(self.properties.script).properties[self.properties.propertyToSet] = self:GetEntity()
end

return NpcInformerScript
