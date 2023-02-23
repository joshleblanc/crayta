local PathScript = {}

-- Script properties are defined here
PathScript.Properties = {
	-- Example property
	{ name = "checkpoints", type = "entity", container = "array" },
	{ name = "onReachCheckpoint", type = "event" },
	{ name = "onLeaveCheckpoint", type = "event" },
	{ name = "camera", type = "entity" }
}

function PathScript:Follow(playerOrUser)
	local user
	if playerOrUser:IsA(User) then
		user = playerOrUser
	elseif playerOrUser:IsA(Character) then
		user = playerOrUser:GetUser()
	else
		return
	end
	
	user:SetCamera(self.properties.camera)
	self:Schedule(function()
		self:GoTo(user, 1)
	end)
end

function PathScript:ProcessEvent(event, user, index)
	local bindings = event:GetAllBindings()
	for _, binding in ipairs(bindings) do
		print("Sending event", binding["function"], user, index)
		binding.script[binding["function"]](binding.script, user, index)
	end
end

function PathScript:GoTo(user, index)
	if index > #self.properties.checkpoints then
		user:SetCamera(user:GetPlayer())
		user:SetMoveOverride(Vector2D.New(1, 1), Vector2D.Zero)
		return
	end
	
	local checkpoint = self.properties.checkpoints[index]
	user.userFollowPathScript:MoveTowards(checkpoint, function()
		user:SetMoveOverride(Vector2D.Zero, Vector2D.Zero)
		self:ProcessEvent(self.properties.onReachCheckpoint, user, index)
		self:ProcessEvent(self.properties.onLeaveCheckpoint, user, index)
		self:GoTo(user, index + 1)
	end)
end

return PathScript
