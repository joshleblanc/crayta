local WorldAlignmentScript = {}

-- Script properties are defined here
WorldAlignmentScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "alignmentController", type = "entity" }
}

--This function is called on the server when this entity is created
function WorldAlignmentScript:Init()
	self.widget = self:GetEntity().worldAlignmentWidget
	
	self:Schedule(function()
		while true do 
			Wait(1)
			local resetTime = self.properties.alignmentController.alignmentControllerScript.resetTime
			local diff = resetTime - GetWorld():GetUTCTime()
			local days = math.floor(diff / 86400)
			local formatTime = Text.FormatTime("{hh} hours {mm} minutes", resetTime - GetWorld():GetUTCTime())
			
			self.widget.properties.timeLeft = tostring(FormatString("{1} days {2} remaining", days, formatTime))
		end
	end)
	
	self:Schedule(function()
		while true do 			
			GameStorage.GetCounter("good-points", function(gp)
				GameStorage.GetCounter("evil-points", function(ep)
					local total = gp + ep 
					
					if total == 0 then 
						self.widget.properties.villainPercent = "50%"
						self.widget.properties.status = 0
					else
						local vp = ep / total
						local percent = math.floor(vp * 100)
						if percent > 0.5 then 
							self.widget.properties.status = -1
						elseif percent < 0.5 then 
							self.widget.properties.status = 1
						else 
							self.widget.properties.status = 0
						end
						self.widget.properties.villainProgress = FormatString("{1}%", percent)
					end
				end)
			end)
			Wait(60)
		end
	end)
end

return WorldAlignmentScript
