local NotifyEveryoneScript = {}

-- Script properties are defined here
NotifyEveryoneScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function NotifyEveryoneScript:Init()
end

function NotifyEveryoneScript:NotifyEveryone(what)
	GetWorld():ForEachUser(function(user)
		if user == self:GetEntity() then 
			user:SendToLocal("AddNotification", FormatString("You {1}", what))
		else
			user:SendToLocal("AddNotification", FormatString("{1} {2}", tostring(self:GetEntity():GetUsername()), what))
		end
	end)
end

return NotifyEveryoneScript
