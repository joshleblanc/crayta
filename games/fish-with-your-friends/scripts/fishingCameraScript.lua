local FishingCameraScript = {}

-- Script properties are defined here
FishingCameraScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "camera", type = "entity" },
	{ name = "stickyPos", type = "vector", editable = false }
}

--This function is called on the server when this entity is created
function FishingCameraScript:Init()
end

function FishingCameraScript:UseFishingCamera(lure)
	print("Using fishing camera")
	local player = self:GetEntity()
	
	local dir = (player:GetPosition() - lure:GetPosition()):Normalize()
	
	local newPos = lure:GetPosition() + (dir * Vector.Distance(player:GetPosition(), lure:GetPosition()))
	newPos = newPos + (Rotation.New(0, -90, 0):RotateVector(dir) * 500)
	newPos.z = newPos.z + 500
	
	self.properties.stickyPos = newPos
	
	self.properties.camera:SetPosition(newPos)
	
	self:LookAtLure(lure)
	player:GetUser():SetCamera(self.properties.camera, 1)
end

function FishingCameraScript:LocalOnTick()
	if self.properties.camera then 
		self.properties.camera:SetPosition(self.properties.stickyPos)
	end
	
end

function FishingCameraScript:LookAtLure(lure)
	local dir = -(self.properties.camera:GetPosition() - lure:GetPosition()):Normalize()
	self.properties.camera:SetRotation(Rotation.FromVector(dir))
end

return FishingCameraScript
