local UserFollowPathScript = {}

-- Script properties are defined here
UserFollowPathScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserFollowPathScript:Init()
end

function UserFollowPathScript:DirectionFromPlayer(player, facing, target)
	local direction = Vector2D.New(target.x - player.x, target.y - player.y):Normalize()
	local output = Vector2D.New(
		-((direction.x * facing.y) - (direction.y * facing.x)),
		(direction.x * facing.x) + (direction.y * facing.y)
	)
	return output
end


function UserFollowPathScript:MoveTowards(thing, callback)
	local player = self:GetEntity():GetPlayer()
	local targetPosition = thing:GetPosition()
	local playerPosition = player:GetPosition()
		
	-- When the camera for the user is set to a camera entity,
	-- the SetMoveOverride becomes relative to the camera's forward direction
	local forward = self:GetEntity():GetCamera():GetForward()
	
	self:GetEntity():SetMoveOverride(Vector2D.Zero, self:DirectionFromPlayer(playerPosition, forward, targetPosition))
	
	self:Schedule(function()
		while true do
			Wait()
			local distance = Vector.Distance(player:GetPosition(), targetPosition)

			if distance < 150 then
				callback()
				break
			end 
		end
	end)
end

return UserFollowPathScript


