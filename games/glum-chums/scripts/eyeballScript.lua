local EyeballScript = {}

-- Script properties are defined here
EyeballScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function EyeballScript:ClientInit()
	self.pupil = self:GetEntity():GetChildren()[1]
	
	self.scale = self:GetEntity().shapeScale
	self.pupilScale = self.pupil.shapeScale
	self.pupilPos = self.pupil:GetRelativePosition()
	
	self:Hide()
	
	--[[
	self.followSchedule = self:Schedule(function()
		while true do 
			local players = {}
			GetWorld():ForEachUser(function(user)
				local player = user:GetPlayer()
				if player then 
					local dist = Vector.Distance(player:GetPosition(), self:GetEntity():GetPosition())
					table.insert(players, {
						player = player,
						dist = dist
					})
				end
			end)
			
			table.sort(players, function(a,b) 
				return a.dist - b.dist
			end)
			
			if players[1] and players[1].dist < 500 then 
				local track = players[1].player
				self:OpenEyes()
				
				local x = self:GetEntity():GetPosition().x - track:GetPosition().x
				local y = self:GetEntity():GetPosition().y - track:GetPosition().y
				local angle = math.atan2(y, x)
				
			
				
				angle = angle - 1
				
				print(x, angle)
					

				local diff = (track:GetPosition() - self:GetEntity():GetPosition()):Normalize()
				--diff = Vector.New(math.abs(diff.x), math.abs(diff.y), math.abs(diff.z))
				local rot = Rotation.FromVector(diff)
				--rot = rot - self:GetEntity():GetRotation()

				rot.yaw = rot.yaw - math.abs(self:GetEntity():GetRotation().yaw) * 2


				self.pupil:SetRelativePosition(Vector.New(self.pupilPos.x, -angle * 12, 0))
				
			
			else
				self:CloseEyes()
			end

			Wait()
		end
	end)
	--]]
end

function EyeballScript:Hide()
	self:GetEntity().visible = false 
	for _, child in ipairs(self:GetEntity():GetChildren()) do 
		child.visible = false
	end
end

function EyeballScript:Show()
	self:GetEntity().visible = true 
	for _, child in ipairs(self:GetEntity():GetChildren()) do 
		child.visible = true
	end
end

function EyeballScript:OpenEyes()
	if self.eyesOpen then return end 
	
	self.eyesOpen = true
	self:Show()
	self.blinkSchedule = self:Schedule(function()
		while true do 
			self:Blink()
			Wait(math.random(1,3))
		end
	end)
end

function EyeballScript:CloseEyes()
	if not self.eyesOpen then return end 
	
	self.eyesOpen = false
	self:Hide()
	if self.blinkSchedule then 
		self:Cancel(self.blinkSchedule)
	end
end

function EyeballScript:Blink()
	self:GetEntity().shapeScale = Vector.New(self.scale.x, self.scale.y, 0)
	self.pupil.visible = false
	Wait(0.1)
	self:GetEntity().shapeScale = self.scale
	self.pupil.visible = true
end

return EyeballScript
