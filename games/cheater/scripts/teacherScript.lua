local TeacherScript = {}

-- Script properties are defined here
TeacherScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "focusLocation", type = "entity" },
	{ name = "rotationController", type = "entity" },
	{ name = "cone", type = "entity" },
	{ name = "sightLocators", type = "entity", container = "array" },
	{ name = "pathStart", type = "entity" },
	{ name = "nervousShake", type = "camerashakeasset" },
	
}

--This function is called on the server when this entity is created
function TeacherScript:Init()
	self.game = GetWorld():FindScript("gameScript")
	
	local pos = self.properties.focusLocation:GetRelativePosition()
	self.properties.focusLocation:PlayRelativeTimelinePingPong(
		0, pos - Vector.New(400, 0, 0),
		5, pos + Vector.New(400, 0, 0)
	)
	
	
	self:LookBackAndForth()
	
	self:WalkAround(self.properties.pathStart)
end

function TeacherScript:WalkAround(node)
	self:GetEntity():ClearLookAt()
	self:GetEntity():MoveToPosition(node:GetPosition(), function()
		self:Schedule(function()
			self:GetEntity():SetLookAtEntity(node:FindScriptProperty("thingToLookAt"))
			Wait(3) -- takes about 3 seconds for the npc to turn after setting their look at 
			self:LookBackAndForth()
			Wait(12)
			self:WalkAround(node:FindScriptProperty("nextNode"))
		end)
		
	end, MovementMode.Walk)
end


function TeacherScript:CalcArea(a,b,c)
	local d = a.x * (b.y-c.y)
	local e = b.x * (c.y - a.y)
	local f = c.x * (a.y-b.y)
	local g = (d + e + f) / 2
	
	return math.abs(g)
end

function TeacherScript:InSight(pos)
	local a = self.properties.sightLocators[1]:GetPosition()
	local b = self.properties.sightLocators[2]:GetPosition()
	local c = self.properties.sightLocators[3]:GetPosition()
	
	local d = self:CalcArea(a,b,c)
	local e = self:CalcArea(pos, b, c)
	local f = self:CalcArea(pos, a, c)
	local g = self:CalcArea(pos, a, b)
	
	
	return d == (e + f +g)
end

function TeacherScript:OnTick()
	self.game:ForEachUser(function(u)
		local player = u:GetPlayer()
		if player and self:InSight(player:GetPosition()) then 
			self:HandleSawPlayer(player)
		elseif player then
			player.playerCheaterGameScript.properties.beingWatched = false
		end
	end)
	
	local rot = self.properties.rotationController:GetRotation()
	local newRot = Rotation.New(0, rot.yaw, -90)
	self.properties.cone:SetRotation(newRot)
end

function TeacherScript:HandleSawPlayer(player)
	if player:FindScriptProperty("isSafe") then
		player.playerCheaterGameScript.properties.beingWatched = false
	return end 
	
	if player:IsAlive() then
		player:ApplyDamage(1, (self:GetEntity():GetPosition() - player:GetPosition()):Normalize(), self:GetEntity())
		player:GetUser():PlayCameraShakeEffect(self.properties.nervousShake,.1)
		player.playerCheaterGameScript.properties.beingWatched = true
	end
end

function TeacherScript:LookBackAndForth()
	self:GetEntity():SetLookAtEntity(self.properties.focusLocation)
end

return TeacherScript
