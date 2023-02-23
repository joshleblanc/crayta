local PayloadPathIndicatorScript = {}

-- Script properties are defined here
PayloadPathIndicatorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "firstTrack", type = "entity" },
	{ name = "lastTrack", type = "entity" },
	{ name = "effect", type = "entity" },
	{ name = "ownerEffects", type = "effectasset", container = "array" }
}

--This function is called on the server when this entity is created
function PayloadPathIndicatorScript:Init()
	
	-- first is team 2's side
	self.first = self.properties.firstTrack
	
	self.transform = self:GetEntity().TWTransform
	
	--self:CollectTracks()
	
	-- last is team 1's side
	--self.last = self.tracks[#self.tracks]
	
	self.dir = 0
	
	--[[
	self:Schedule(function()
		local i = 1
		while true do 
			local time = self.properties.effect:AlterPosition(self.tracks[i + self.dir]:GetPosition(), 1)
			Wait(time)
			i = i + self.dir
			if i >= #self.tracks then
				i = 1
				self.properties.effect:SetPosition(self.first:GetPosition())
			elseif i <= 1 then 
				i = 12
				self.properties.effect:SetPosition(self.last:GetPosition())
			end
		end
	end)
	]]--
end

function PayloadPathIndicatorScript:OnTick()
	local state = self.transform:GetState()
	state = self.transform:CalculateMovementState(150 * -self.dir, state)
	if state.outOfTrack then 
		print("out of track", self.dir)
		if self.dir == 1 then 
			print("Moving cart to first track")
			self.transform:SetState({ track = self.properties.firstTrack.TWTrackSection, t = 0, tDirection = 1 })
		elseif self.dir == -1 then 
			print("moving cart to last track")
			self.transform:SetState({ track = self.properties.lastTrack.TWTrackSection, t = 1, tDirection = 1 })
		end 
	end
end

function PayloadPathIndicatorScript:HandleOwnerChange(owner)
	if owner == 0 then 	
		self.dir = 0
		self.properties.effect.effect = nil
	elseif owner == 1 then 
		self.dir = 1
		self.properties.effect.effect = self.properties.ownerEffects[3]
	elseif owner == 2 then 
		self.dir = -1
		self.properties.effect.effect = self.properties.ownerEffects[2]
	end
end

function PayloadPathIndicatorScript:CollectTracks()
	self.tracks = { self.first }
	
	local transform = self:GetEntity().TWTransform
	transform:Init()
	local state = transform:GetState()
	state = transform:CalculateMovementState(100 * state.tDirection, state)
	local track = self.first
	while state.outOfTrack ~= true do 
		if state.track ~= track and state.track then 
			table.insert(self.tracks, state.track:GetEntity())
		end
		
		track = state.track
		
		state = transform:CalculateMovementState(100 * state.tDirection, state)
	end
end

return PayloadPathIndicatorScript
