local RangeIndicatorScript = {}

-- Script properties are defined here
RangeIndicatorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "range", type = "number", default = 1000 },
	{ name = "ownershipEffects", type = "effectasset", container = "array" },
	{ name = "effectRoot", type = "entity" },
	{ name = "effect", type = "entity" },
	{ name = "owner", type = "number", default = 1, editable = false },
	{ name = "onOwnerChange", type = "event" }
}

--This function is called on the server when this entity is created
function RangeIndicatorScript:Init()
	
	local size = self.properties.range * 2
	self:GetEntity().size = Vector.New(size, size, 250)
	self.properties.effect:SetRelativePosition(Vector.New(self.properties.range, 0, -50))

	--self:OwnershipSchedule()
	self:PurgeSchedule()
	
	self:Reset()
end

function RangeIndicatorScript:ClientInit()
	self:RotationSchedule()
end

function RangeIndicatorScript:PurgeSchedule()
	self:Schedule(function()
		while true do 
			for i, arr in ipairs(self.counts) do
				local newCounts = {}
				for _, p in ipairs(arr) do 
					if p:IsValid() and p:IsAlive() then 
						table.insert(newCounts, p)
					end
				end
				self.counts[i] = newCounts
			end
			self:AdjustEffect()
			Wait(1)
		end
	end)
end

function RangeIndicatorScript:RotationSchedule()
	self:Schedule(function()
		while true do 
			local alter = self.properties.effectRoot:AlterRotation(Rotation.Zero, Rotation.New(0, 360 * 1000, 0), 5 * 1000)
			Wait(alter)
		end
	end)
end

function RangeIndicatorScript:OnTriggerEnter(player)
	local isGhost = player:FindScriptProperty("isGhost")
	
	print("range indicator script:", player:GetUser():GetUsername(), "entered", isGhost)
	
	if isGhost then return end 
	
	self:AddPlayer(player)
	
	self:AdjustEffect()
end

function RangeIndicatorScript:AddPlayer(player)
	local team = player:GetUser():FindScriptProperty("team")

	table.insert(self.counts[team], player)
end

function RangeIndicatorScript:RemovePlayer(player)
	local team = player:GetUser():FindScriptProperty("team")
	
	local ind = self:FindPlayer(self.counts[team], player)
	if ind then 
		table.remove(self.counts[team], ind)
	end
end

function RangeIndicatorScript:FindPlayer(arr, player)
	for i, p in ipairs(arr) do
		if p == player then 
			return i
		end
	end
end

function RangeIndicatorScript:HasPlayers()
	return #self.counts[1] > 0 or #self.counts[2] > 0
end

function RangeIndicatorScript:OnTriggerExit(player)
	local isGhost = player:FindScriptProperty("isGhost")
	
	print("range indicator script:", player:GetUser():GetUsername(), "exited", isGhost)
	
	if isGhost then return end 
	
	self:RemovePlayer(player)
	
	self:AdjustEffect()
end

function RangeIndicatorScript:Reset()
	self.counts = { {}, {} }
	self:AdjustEffect()
end

function RangeIndicatorScript:AdjustEffect()
	if #self.counts[1] > #self.counts[2] then 
		self.properties.owner = 1
	elseif #self.counts[2] > #self.counts[1] then 
		self.properties.owner = 2
	else 
		self.properties.owner = 0
	end
	
	self.properties.effect.effect = self.properties.ownershipEffects[self.properties.owner + 1]
	self.properties.onOwnerChange:Send(self.properties.owner, #self.counts[1], #self.counts[2])
end

return RangeIndicatorScript
