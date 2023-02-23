local AlignmentControllerScript = {}

-- Script properties are defined here
AlignmentControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function AlignmentControllerScript:Init()
	
	Leaderboards.GetMetadata("good-points", function(data)
		self.initTime = data.resetTime
		
		GameStorage.GetCounter("season-time", function(v)
			if v == 0 then -- first run
				GameStorage.UpdateCounter("season-time", data.resetTime)
				self.initTime = data.resetTime
			elseif data.resetTime > v then -- if the leaderboard reset time is greater than the season time, roll the season
				self:RollSeason(data)
			else
				self.initTime = v
			end
		end)
	end)
	
	self.resetTime = 0
	
	self:Schedule(function()
		while true do 			
			Leaderboards.GetMetadata("good-points", function(data)
				self.resetTime = data.resetTime
				if self.initTime and self.initTime < data.resetTime then  -- if the leaderboard's reset time is greater than it was when we started, then the season must have rolled
					self:RollSeason(data)
				end
			end)
			Wait(10)
		end
	end)
end

function AlignmentControllerScript:RollSeason(data)
	self.initTime = data.resetTime
	
	self:ResetCounter("last-winner")
	self:ResetCounter("season-time")
	
	GameStorage.UpdateCounter("season-time", data.resetTime)
	
	GameStorage.GetCounter("world-alignment", function(v)
		GameStorage.UpdateCounter("last-winner", v)
	end)
	
	self:ResetCounter("good-points")
	self:ResetCounter("evil-points")
	self:ResetCounter("world-alignment")
end

function AlignmentControllerScript:ResetCounter(id)
	GameStorage.GetCounter(id, function(val)
		GameStorage.UpdateCounter(id, val * -1)
	end)
end

function AlignmentControllerScript:OnMissionCompleted(roomEntity, availableMissionDoc, result)
	if result ~= "success" then return end 
	
	local alignment = availableMissionDoc.data.alignment
	local id = FormatString("{1}-points", alignment)
	
	local inc = 1
	if alignment == "evil" then 
		inc = -1
	end
	
	print("Mission completed")
	
	GameStorage.UpdateCounter(id, 1)
	GameStorage.UpdateCounter("world-alignment", inc)
end

return AlignmentControllerScript
