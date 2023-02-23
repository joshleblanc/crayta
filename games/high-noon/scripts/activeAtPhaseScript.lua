local ActiveAtPhaseScript = {}

-- Script properties are defined here
ActiveAtPhaseScript.Properties = {
	{ name = "phase", type = "string", options = { "search", "destroy" }, default = "destroy" }
}

function ActiveAtPhaseScript:OnSearch()
	self:GetEntity().visible = self.properties.phase == "search"
end

function ActiveAtPhaseScript:OnDestroy()
	self:GetEntity().visible = self.properties.phase == "destroy"
end

return ActiveAtPhaseScript
