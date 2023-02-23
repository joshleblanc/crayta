local UserCompassScript = {}

-- Script properties are defined here
UserCompassScript.Properties = {
	{ name = "hideBar", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function UserCompassScript:Init()
end

function UserCompassScript:LocalInit()
	print("Initializing user compass script")
	self.targets = self:GetEntity():FindAllScripts("compassTargetScript")
	self.widget = self:GetEntity().userCompassWidget
	
	self.widget:CallFunction("ResetTargets")
	self.widget.js.data.hideBar = self.properties.hideBar
	
	if #self.targets == 0 then
		self.widget:Hide()
	end
end

function UserCompassScript:SetTargets(targets)
	if IsServer() then 
		self:SendToLocal("SetTargets", targets)
		return
	end
	
	print("Setting targets", #targets)
	
	self.targets = targets
	
	if #self.targets > 0 then
		self.widget:Show()
	end
end

function UserCompassScript:AddTarget(target, eye, lookAt)
	local targetPos = target.properties.entity:GetPosition()
	
	-- We don't care about the Z axis, and it makes all the math easier, 
	-- so convert these to Vector2D
	local dirA = (lookAt - eye):Normalize()
	dirA = Vector2D.New(dirA.x, dirA.y)
	
	local dirB = (targetPos - eye):Normalize()
	dirB = Vector2D.New(dirB.x, dirB.y)
	
	local angleDir = -dirA.x * dirB.y + dirA.y * dirB.x

	local dot = Vector2D.Dot(dirA, dirB)
	dot = dot / (dirA:Length() * dirB:Length())
	
	local angle = math.deg(math.acos(dot))
	
	if angleDir > 0 then
		angle = -angle
	end
	
	local distance = Vector.Distance(eye, targetPos)
	
	local screenPos
	if target.properties.displayWorldIndicator and (target.properties.alwaysDisplayWorldIndicator or distance <= target.properties.worldIndicatorMinimumDistance) then
		screenPos = self:GetEntity():ProjectPositionToScreen(targetPos)
	end

	self.widget:CallFunction("AddTarget", 
		target.properties.id,
		angle,
		target.properties.name,
		target.properties.indicator,
		target.properties.codePoint,
		{ 
			red = math.floor(target.properties.color.red * 255),
			green = math.floor(target.properties.color.green * 255),
			blue = math.floor(target.properties.color.blue * 255)
		},
		target.properties.imageUrl,
		distance,
		target.properties.fadeIcon,
		screenPos,
		target.properties.alwaysDisplayWorldIndicator,
		target.properties.keepWorldIndicatorOnScreen,
		target.properties.pulse,
		target.properties.showDistance,
		target:IsVisible(distance)
	)
end

function UserCompassScript:LocalOnTick()
	if not self.widget.visible then return end 

	self.widget:CallFunction("ResetTargets")

	local player = self:GetEntity():GetPlayer()
	if not player then return end
	
	local playerPosition = player:GetPosition()
	local eye, lookAt = player:GetLookAt()
	for i=1,#self.targets do
		local target = self.targets[i]
		
		self:AddTarget(target, eye, lookAt)
	end
	self.widget:CallFunction("SyncModels");
end

function UserCompassScript:Show()
	self.widget:Show()
end

function UserCompassScript:Hide()
	self.widget:Hide()
end

return UserCompassScript
