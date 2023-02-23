local AttachToChampion = {}

-- Script properties are defined here
AttachToChampion.Properties = {
	-- Example property
	{name = "attachToParent", type = "boolean", tooltip = "Attach to parent?", default = true},
	{name = "attachTo", type = "entity", visibleIf=function(p) return not p.attachToParent end},
	{name = "socket", type = "string", tooltip = "What socket will the entity be attached to?", options = {"spine_01", "spine_02", "spine_03", "spine_04", "spine_05",
                "neck_01", "neck_02", "head", "clavicle_l", "shoulder_l", "upperarm_l", "lowerarm_l",
                "hand_l", "weapon_l", "clavicle_r", "shoulder_r", "upperarm_r", "lowerarm_r", "hand_r",
                "weapon_r", "thigh_l", "calf_l", "foot_l", "thigh_r", "calf_r", "foot_r",}, default = "spine_01"},
	{name = "relativePosition", type = "vector", tooltip = "Entity position relative to the entity it is attached to."},
	{name = "relativeRotation", type = "rotation", tooltip = "Entity rotation relative to the entity it is attached to."},
	{name = "scale", type = "vector", tooltip = "Entity scale.", default = Vector.New(1,1,1)},
	
}

--This function is called on the server when this entity is created
function AttachToChampion:Init()
	self.attachToEntity = self:GetEntity():GetParent()
	if self.properties.attachToParent then
		--print("Attach to parent")
		self:GetEntity():AttachTo(self:GetEntity():GetParent(), self.properties.socket)
	else
		if self.properties.attachTo then
			--printf("Attach to {1}", self.properties.attachTo:GetName())
			self:GetEntity():AttachTo(self.properties.attachTo, self.properties.socket)
		else
			printf("{1} cannot be attached to an entity. Make the entity child of the NPC and enable 'attachToParent' property.", self:GetEntity():GetName())
		end
	end
	
	
	self:GetEntity():SetRelativePosition(self.properties.relativePosition)
	self:GetEntity():SetRelativeRotation(self.properties.relativeRotation)
	self:GetEntity().meshScale = self.properties.scale
end

return AttachToChampion
