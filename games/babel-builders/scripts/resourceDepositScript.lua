local ResourceDepositScript = {}

-- Script properties are defined here
ResourceDepositScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "name", type = "string" },
	{ name = "team", type = "number", options = { 1, 2 }, default = 1 },
	{ name = "gameStorageController", type = "entity" },
	{ name = "stat", type = "string", options = { "speed", "strength" } }
}

--This function is called on the server when this entity is created
function ResourceDepositScript:Init()
	self.entity = nil
	self:CheckStatus()
end

function ResourceDepositScript:GetUpgrades()
	self.upgrades = self.upgrades or self:GetEntity():FindAllScripts("resourceDepositUpgradeScript")
	return self.upgrades
end


function ResourceDepositScript:CheckStatus()
	local script, wood, stone = self:GetLevel()
	
	if not script then return end 
	
	if IsServer() then
		local tmp = GetWorld():Spawn(script.properties.template, script.properties.locator)
		if self.entity then
			self.entity:Destroy()
		end
		
		self.entity = tmp
		
		self:SendToAllClients("UpdateWidgetFromLevel", script, wood, stone)
	else
		self:UpdateWidgetFromLevel(script, wood, stone)
	end
end

-- This has a side effect of updating users with the stats of achieved 
-- upgrades
function ResourceDepositScript:GetLevel()
	local storage = self.properties.gameStorageController.gameStorageControllerScript
	local woodCollected = storage:Get(self:GetWoodId())
	local stoneCollected = storage:Get(self:GetStoneId())
	
	local totalWood = 0
	local totalStone = 0
	local totalStat = 0
	
	if IsServer() then
		GetWorld():ForEachUser(function(user)
			local team = user:FindScriptProperty("team")
			if team == self.properties.team then
				user.userStatsScript:Reset()
			end
		end)
	else
		GetWorld():GetLocalUser().userStatsScript:Reset(self.properties.stat)
	end
	
	local upgrades = self:GetUpgrades()
	for i, script in ipairs(upgrades) do 
		totalWood = totalWood + script.properties.wood
		totalStone = totalStone + script.properties.stone
		totalStat = totalStat + script.properties.statPercent
		
		if not (woodCollected >= totalWood and stoneCollected >= totalStone) then
			local woodLeft = woodCollected - (totalWood - script.properties.wood)
			local stoneLeft = stoneCollected - (totalStone - script.properties.stone)
			return script, woodLeft, stoneLeft, totalStat
		else
			if IsServer() then 
				GetWorld():ForEachUser(function(user)
					local team = user:FindScriptProperty("team")
					if team == self.properties.team then
						user.userStatsScript:Add(script.properties.stat, script.properties.statPercent)
					end
				end)
			else
				GetWorld():GetLocalUser().userStatsScript:Add(script.properties.stat, script.properties.statPercent)
			end
		end
	end
end

function ResourceDepositScript:ClientInit()
	self.widget = self:GetEntity():FindWidget("resourceDepositWidget", true)
	self.widget.js.data.name = self.properties.name
	
	self:CheckStatus()
end

function ResourceDepositScript:UpdateWidgetFromLevel(level, wood, stone)
	if level then
		self.widget.js.data.level = level.properties.level
		self.widget.js.data.requiredWood = level.properties.wood
		self.widget.js.data.requiredStone = level.properties.stone
		self.widget.js.data.wood = wood
		self.widget.js.data.stone = stone
	end
end

function ResourceDepositScript:HandleStorageUpdate(key, value)
	local stoneId = self:GetStoneId()
	local woodId = self:GetWoodId()
	
	if key == stoneId then
		self:UpdateWidget("stone", value)
		self:CheckStatus()
	end
	
	if key == woodId then
		print("Wood updated", woodId, key, value)
		self:UpdateWidget("wood", value)
		self:CheckStatus()
	end
end

function ResourceDepositScript:GetInteractPrompt(prompts, player)
	local holding = player:FindScriptProperty("holding")
	
	if holding then
		prompts.interact = FormatString("Deposit {1}", holding:FindScriptProperty("resource"))
	else
		prompts.interact = "Inspect"
	end
	
end

function ResourceDepositScript:OnInteract(player)
	local user = player:GetUser()
	local userTeam = user:FindScriptProperty("team")
	if userTeam ~= self.properties.team then
		user:SendToScripts("Shout", "This isn't your team!")
		return
	end
	
	local holding = player:FindScriptProperty("holding")
	
	if holding then
		local resource = holding:FindScriptProperty("resource")
		print(FormatString("{1}-{2}", self:GetId(), resource))
		self.properties.gameStorageController.gameStorageControllerScript:Update(FormatString("{1}-{2}", self:GetId(), resource), 1)
		user:AddToLeaderboardValue(FormatString("{1}-collected", resource), 1)
		user:SendXPEvent("resource", { action = "dropoff" })
		user.userWealthScript:Add(1)
		player:SendToScripts("RemoveResource")
	else
		user.userResourceDepositScript:SendToLocal("Show", self)
	end
end

function ResourceDepositScript:GetId()
	return FormatString("{1}-{2}", self.properties.team, self.properties.name)
end

function ResourceDepositScript:GetLevelId()
	return FormatString("{1}-level", self:GetId())
end

function ResourceDepositScript:GetWoodId()
	return FormatString("{1}-wood", self:GetId())
end

function ResourceDepositScript:GetStoneId()
	return FormatString("{1}-stone", self:GetId())
end

function ResourceDepositScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToAllClients("UpdateWidget", key, value)
		return
	end
	
	self.widget.js.data[key] = value
end

return ResourceDepositScript
