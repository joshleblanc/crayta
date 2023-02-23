local PlayerMovementSound = {}

-- Script properties are defined here
PlayerMovementSound.Properties = {
	-- Example property
	
}

--This function is called on the server when this entity is created
function PlayerMovementSound:Init()
end

function PlayerMovementSound:LocalInit()
	self.localCount = 0
end

function PlayerMovementSound:LocalOnButtonPressed(button)
	if button == "forward" or button == "backward" or button == "left" or button == "right" then
		
		self.localCount = self.localCount +1
	end
end


function PlayerMovementSound:LocalOnButtonReleased(button)
	if  button == "forward" or button == "backward" or button == "left" or button == "right" then
		self.localCount = self.localCount -1
		
	end
end

function PlayerMovementSound:LocalOnTick()
local player = self:GetEntity():GetParent():GetPlayer()
	if self.localCount > 0 and player then
		self:GetEntity().pitch = player.speedMultiplier
		self:GetEntity().active = true
	else
		self:GetEntity().active = false
	end
end


return PlayerMovementSound
