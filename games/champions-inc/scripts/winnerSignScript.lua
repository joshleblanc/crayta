local WinnerSignScript = {}

-- Script properties are defined here
WinnerSignScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function WinnerSignScript:Init()
	self.widget = self:GetEntity().winnerSignWidget
	self:Schedule(function()
		while true do 
			Wait(60)
			
			GameStorage.GetCounter("last-winner", function(v)
				if v > 0 then 
					self.widget.properties.signText = Text.Format("Heroes")
				elseif v < 0 then 
					self.widget.properties.signText = Text.Format("Villains")
				else 
					self.widget.properties.signText = Text.Format("No Winner")
				end
			end)
		end
	end)
end

return WinnerSignScript
