local ZiplineScript = {}

-- Script properties are defined here
ZiplineScript.Properties = {
	-- Example property
	{ name = "startAnchor", type = "entity" },
	{ name = "endAnchor", type = "entity" },
	{ name = "interactPrompt", type = "text" },
	{ name = "ziplineGrip", type = "gripasset" },
	{ name = "ziplineHandle", type = "template" },
	{ name = "speed", type = "number", default = 400 },
	{ name = "canGoBackwards", type = "boolean", default = false }
}

function ZiplineScript:Init()
	self.distance = Vector.Distance(self.properties.endAnchor:GetPosition(), self.properties.startAnchor:GetPosition())
	self.direction = (self.properties.endAnchor:GetPosition() - self.properties.startAnchor:GetPosition()):Normalize()
	--self:CreateZipline()
end

function ZiplineScript:Travel(player, startPoint, endPoint)
	local speed = self.distance / self.properties.speed
	self:Schedule(function()
		player:SetInputLocked(true)

		local start = startPoint:GetPosition()
		start.z = start.z - 125
		
		local endd = endPoint:GetPosition()
		endd.z = endd.z - 125
		
		local dir = (endd - start):Normalize()
		
		start = start + (dir * 100)
		endd = endd - (dir * 100)
		
		player:AdjustAim(
			100, endd
		)
		
		local handle = GetWorld():Spawn(self.properties.ziplineHandle, Vector.Zero, Rotation.Zero)
		handle:AttachTo(player, "hand_r")
		
		--handle:SetRotation(Rotation.New(230, 0, 30))
		
		player:SetGrip(self.properties.ziplineGrip)
		Wait()
		
		Wait(player:PlayTimeline(
			0, start, "Linear",
			speed, endd, "EaseIn"
		))
		
		player:SetNoGrip()
		handle:Destroy()
		player:SetInputLocked(false)
	end)
end

function ZiplineScript:MovePlayer(player, startPoint, endPoint)
	--[[
	if IsServer() then
		self:SendToAllClients("MovePlayer", player, startPoint, endPoint)
	end
	
	local time = 0
	local speed = self.distance / self.properties.speed
	
	while time < speed do 
		local dt = Wait()
		time = time + dt
		
		local percent = time / speed
		local start = startPoint:GetPosition()
		start.z = start.z - 150
		
		local endd = endPoint:GetPosition()
		endd.z = endd.z - 150
		
		local distance =  Vector.Distance(endd, start)
		
		local direction = (endd - start):Normalize()
		local newPos = start + (direction * (distance * percent))
		
		player:SetPosition(newPos)
	end
	--]]

end

function ZiplineScript:OnTriggerInteractForward(player)
	self:Travel(player, self.properties.startAnchor, self.properties.endAnchor)
end

function ZiplineScript:OnTriggerInteractBackward(player)
	if not self.properties.canGoBackwards then return end 
	
	self:Travel(player, self.properties.endAnchor, self.properties.startAnchor)
end

return ZiplineScript
