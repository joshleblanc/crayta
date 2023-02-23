local XPTimeAwardScript = {}

-- Script properties are defined here
XPTimeAwardScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function XPTimeAwardScript:Init()
	self:Schedule(function()
		while true do 
			Wait(5)
			local users = GetWorld():GetUsers()
			if users then
				if #users < 2 and #users > 0 then
					for i=1, #users do
						users[i]:SendXPEvent("cruising-time-low")
					end
				elseif #users >= 2 then
					for i=1, #users do
						users[i]:SendXPEvent("cruising-time-mid")
					end
				end
			end
			Wait(20)
		end
	end)
end



return XPTimeAwardScript
