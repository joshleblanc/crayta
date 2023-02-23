local StareAt = {}

StareAt.Properties = {
	{ name = "target", type = "entity", default = nil, editable = false },
	{ name = "crosshair", type = "entity", editable = false },
	{ name = "crosshairTemplate", type = "template"}
}

function StareAt:DestroyCrosshair()
	if self.properties.crosshair then
		self.properties.crosshair:Destroy()
		self.properties.crosshair = nil
	end
end

function StareAt:OnTick(dt)
	if not self.properties.crosshair then
		self.properties.crosshair = GetWorld():Spawn(self.properties.crosshairTemplate, Vector.Zero, Rotation.Zero)
		self.properties.crosshair.visible = false
	end
	if not self:GetEntity():IsAlive() then
		self:DestroyCrosshair()
	end
end

function StareAt:LocalOnButtonPressed(button)
	if button == "secondary" then
		self:SelectSomeoneElse()
	end
end

function StareAt:LocalOnTick(dt)
	if self.properties.crosshair and self.properties.target and self.properties.target:IsAlive() then
		self:AttachCrosshair(self.properties.target, self.properties.crosshair)
		self:ShowCrosshair()
	else
		self:HideCrosshair()
	end
	

	if not self:TargetAvailable(self.properties.target) then
		self:SetTarget(self:ClosestPlayer())
	end
	
	if self.properties.target then
		local dir = (self:GetEntity():GetPosition() - self.properties.target:GetPosition()):Normalize()
		self:GetEntity().movementFix:SendToScript("AdjustDirection", dir)
	else
		self:GetEntity().movementFix:SendToScript("Restore")
	end
end

function StareAt:TargetAvailable(target)

	if not target then
		return false
	end
	
	local myTeam = self:GetEntity():GetUser():FindScriptProperty("team")
	local team = target:GetUser():FindScriptProperty("team")
		
	if not target:IsAlive() or target == self:GetEntity() or team == myTeam then
		return false
	end
	
	if Vector.Distance(target:GetPosition(), self:GetEntity():GetPosition()) > 2150 then
		return false
	end

	--if not self:lookingAt(target) then
	--	return false
	--end
	
	return true
end

function StareAt:SetTarget(player)
	-- We're not returning here because we want to client updated asap
	-- but self.properties.target isn't impliclty sent back to the server, so we
	-- do have to do it manually too
	if not IsServer() then
		self:GetEntity():SendToServer("SetTarget", player)
	end
	self.properties.target = player
end

function StareAt:AttachCrosshair(entity, crosshair)
	if not IsServer() then
		self:GetEntity():SendToServer("AttachCrosshair", entity, crosshair)
		return
	end
	crosshair:AttachTo(entity, "head")
end

function StareAt:ShowCrosshair()
	if self.properties.crosshair then
		self.properties.crosshair.visible = true
	end
end

function StareAt:HideCrosshair()
	if self.properties.crosshair then
		self.properties.crosshair.visible = false
	end
end

function StareAt:lookingAt(target)
	local head = self:GetEntity():GetPosition()
	local looking = self:GetEntity():GetForward()
	local lookingDir = math.abs(looking.y) / looking.y

	local directionOfClosestPlayer = (target:GetPosition() - head)
	local targetDir = math.abs(directionOfClosestPlayer.y) / directionOfClosestPlayer.y
	
	return targetDir == lookingDir
end


-- This code relies on GetUsers returning users in a deterministic fashion
-- no sweet clue if it does or not
function StareAt:SelectSomeoneElse()
	local index = 1
	local users = GetWorld():GetUsers()
	for i, user in pairs(users) do
		if user:GetPlayer() == self.properties.target then
			index = i
		end
	end
	
	for i=index, #users do
		local player = users[i]:GetPlayer()
		if player ~= self.properties.target and self:TargetAvailable(player) then
			self:SetTarget(users[i]:GetPlayer())
			return
		end
	end
	
	-- If we didn't find anything in the top half of the array, check the bottom half
	-- Should be roughly equivelant to wrapping around
	for i=1, index do
		local player = users[i]:GetPlayer()
		if player ~= self.properties.target and self:TargetAvailable(player) then
			self:SetTarget(users[i]:GetPlayer())
			return
		end
	end
end

function StareAt:AvailablePlayers()
	local players = {}
	local myTeam = self:GetEntity():GetUser():FindScriptProperty("team")
	GetWorld():ForEachUser(function(user)
		
		if not self:TargetAvailable(user:GetPlayer()) then
			return
		end
		
		table.insert(players, user:GetPlayer())
	end)

	return players
end

function StareAt:ForEachPlayer(fn)
	local co = coroutine.create(fn)
	for k, player in pairs(self:AvailablePlayers()) do
		coroutine.resume(co, player)
	end
end

function StareAt:ClosestPlayer()
	local position = self:GetEntity():GetPosition()
	if not position then
		return
	end
	local closestPlayer = nil
	self:ForEachPlayer(function(player)
		if closestPlayer == nil then
			closestPlayer = player
		else
			local newDistance = Vector.Distance(player:GetPosition(), position)
			local oldDistance = Vector.Distance(closestPlayer:GetPosition(), position)
			if newDistance < oldDistance then
				closestPlayer = player
			end	
		end
	end)
	return closestPlayer
end

return StareAt
