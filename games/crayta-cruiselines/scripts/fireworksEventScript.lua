local FireworksEventScript = {}

-- Script properties are defined here
FireworksEventScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "effect", type = "effectasset" }
}

--This function is called on the server when this entity is created
function FireworksEventScript:Init()
	self.entity = self:GetEntity()
	self.children = self.entity:GetChildren()
end

function FireworksEventScript:Run(event)
	GetWorld():ForEachUser(function(user)
		local player = user:GetPlayer()
		if player then
			event:RewardParticipation(player)
		end
	end)
	self.clones = {}
	local timeRun = 0
	
	self:Schedule(function()
		-- play in a line
		self:FireLine(1)
		
		Wait(1)
		
		self:FireAll()
		
		Wait(1)
		
		self:FireAll()
		
		Wait(1)
		
		self:FireAll()
		
		Wait(1)
		
		self:FireLine(0.4)		
		self:FireLineBackwards(0.4)
		self:FireLine(0.4)
		self:FireLineBackwards(0.4)
		
		Wait(1)
		
		self:FireAll()
		
		Wait(1)
		
		self:FireAll()
		
		Wait(1)
		
		self:FireAll()
		
		Wait(3)
		
		for i=1,10 do
			self:FireAll()
			Wait(0.1)
		end
		
		Wait(1)
		
		for i=1,10 do
			self:FireAll()
			Wait(0.1)
		end
		
		Wait(1)
		
		for i=1,10 do
			self:FireAll()
			Wait(0.1)
		end
		
		Wait(1)
		
		for i=1,5 do
			self:FireLine(0.1)
			self:FireLineBackwards(0.1)
		end
		
		local lineHandle = self:Schedule(function()
			for i=1,10 do
				self:FireLine(0.1)
			end
		end)
		
		local backwardsHandle = self:Schedule(function()
			for i=1,10 do
				self:FireLineBackwards(0.1)
			end
		end)
		
		Wait(0.1 * #self.children * 10) -- Wait for those other things to finish
		
		for i=1,50 do
			self:FireAll()
			Wait(0.1)
		end

		
		Wait(10)
		
		self:KillAllClones()
	end)
end

function FireworksEventScript:KillAllClones()
	for _, v in ipairs(self.clones) do
		v:Destroy()
	end
end

function FireworksEventScript:FireLine(delay)
	for _, effect in ipairs(self.children) do
		self:Fire(effect)
		Wait(delay)
	end
end

function FireworksEventScript:FireLineBackwards(delay)
	for i=#self.children,1,-1 do 
		self:Fire(self.children[i])
		Wait(delay)
	end
end


function FireworksEventScript:FireAll()
	for _, effect in ipairs(self.children) do
		self:Fire(effect)
	end
end

function FireworksEventScript:Fire(effect)
	self:Schedule(function()
		local clone = effect:Clone()
		clone.active = true
		Wait(2)
		clone.active = false
		table.insert(self.clones, clone)
	end)
end

return FireworksEventScript
