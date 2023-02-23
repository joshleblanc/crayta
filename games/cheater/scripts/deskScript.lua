local DeskScript = {}

-- Script properties are defined here
DeskScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "npc", type = "entity" },
	{ name = "chair", type = "entity" },
	{ name = "indicator", type = "entity" },
	{ name = "indicatorLight", type = "entity" },
	{ name = "indicatorEffect", type = "entity" },
	{ name = "obstructions", type = "meshasset", container = "array" },
	{ name = "obstructionEntity", type = "entity" },
	{ name = "obstructionBlocker", type = "entity" },
	{ name = "trigger", type = "entity" },
	{ name = "chairBlocker", type = "entity" }
}

--This function is called on the server when this entity is created
function DeskScript:Init()
	self.properties.trigger.onTriggerEnter:Listen(self, "HandleTriggerEnter")
	self.properties.trigger.onTriggerExit:Listen(self, "HandleTriggerExit")
	self.indicatorChildren = self.properties.indicator:GetChildren()
	
	self:Deactivate()
	
	self:Schedule(function()
		Wait()
		self.properties.npc:StartOccupy(self.properties.chair)
	end)
end

function DeskScript:ClientInit()
	self.indicatorChildren = self.properties.indicator:GetChildren()
end

function DeskScript:HandleTriggerEnter(player)
	if player:IsA(Character) then 
		if player:GetUser() == self.owner then 
			player.playerCheaterGameScript.properties.isSafe = true
		else 
			player:GetUser().userCheaterScript:StartProgressingObjective(self)
		end
	end
end

function DeskScript:HandleTriggerExit(player)
	if player:IsA(Character) then 
		if player:GetUser() == self.owner then 
			if player.playerCheaterGameScript then 
				player.playerCheaterGameScript.properties.isSafe = false
			end
		else 
			player:GetUser().userCheaterScript:StopProgressingObjective(self)
		end
	end
	
end

function DeskScript:ActivateSpawnPoint(user)
	self.isSpawn = true
	self.owner = user
	self.properties.npc.visible = false
	self.properties.chairBlocker.collisionEnabled = false
	print("Turning off chair blocker", self:GetEntity())
end



function DeskScript:Activate()
	self.properties.indicator.visible = true	
	for i=1, #self.indicatorChildren do
		self.indicatorChildren[i].visible = true
	end
end

function DeskScript:Deactivate()
	self.isSpawn = false
	self.owner = nil
	for i=1, #self.indicatorChildren do
		self.indicatorChildren[i].visible = false
	end
	self.properties.npc.visible = true
	self.properties.indicator.visible = false
	self.properties.obstructionEntity.visible = false
	self.properties.obstructionBlocker.collisionEnabled = false
	self.properties.chairBlocker.collisionEnabled = true
	print("Turning on chair blocker", self:GetEntity())
	
end

function DeskScript:AddObstruction()
	print("Adding obstruction")
	local obstruction = self.properties.obstructions[math.random(1, #self.properties.obstructions)]
	self.properties.obstructionEntity.mesh = obstruction 
	self.properties.obstructionEntity.visible = true
	self.properties.obstructionBlocker.collisionEnabled = true
end

return DeskScript
