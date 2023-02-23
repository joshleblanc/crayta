local BoundScript = {}

-- Script properties are defined here
BoundScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function BoundScript:Init()
	self.controller = GetWorld():FindScript("arenaControllerScript")
	self.contains = {}
end

function BoundScript:OnTick()
	for _, d in ipairs(self.contains) do 
		d.entity:SetVelocity(d.vel)
	end
end

function BoundScript:OnTriggerExit(entity)
	local ind
	for i=#self.contains,1,-1 do 
		local d = self.contains[i]
		if d.entity == entity or not Entity.IsValid(d.entity) then 
			table.remove(self.contains, i)
			d.entity.ballScript.lastRedirectPos = d.entity:GetPosition()
		end
	end
end

function BoundScript:OnTriggerEnter(entity)
	if not entity or not entity:FindScriptProperty("isBall") then 
		return
	end
	
	local ignoredEntities = { unpack(self.controller.balls) }
	for _, paddle in ipairs(self.controller.paddles) do 
		table.insert(ignoredEntities, paddle.playerPaddleScript.properties.bounceTrigger)
		table.insert(ignoredEntities, paddle.playerPaddleScript.properties.inactiveTrigger)
		table.insert(ignoredEntities, paddle.playerPaddleScript.properties.paddle)
		table.insert(ignoredEntities, paddle.playerPaddleScript.properties.baseTrigger)
		table.insert(ignoredEntities, paddle.playerPaddleScript.properties.safeguardTrigger)
	end
	
	for i=1,#self.controller.properties.mapBounds do 
		if self.controller.properties.mapBounds[i] ~= self:GetEntity() then 
			print("Adding bound")
			table.insert(ignoredEntities, self.controller.properties.mapBounds[i])
		end
	end
	
	GetWorld():Raycast(entity.ballScript.lastRedirectPos, entity.ballScript:GetTargetRay(), ignoredEntities, function(hitEntity, hitResult)
		print("Hit entity", hitEntity and hitEntity:GetName(), entity.ballScript.lastRedirectPos, entity:GetPosition())
		if not hitEntity then return end 
		
		table.insert(self.contains, { entity = entity, vel = entity.ballScript:CalcRedirectVelocity(hitEntity, hitResult) } )
		--	entity:SendToScripts("SimpleRedirect", hitEntity, hitResult)
	end)
	
	
end

return BoundScript