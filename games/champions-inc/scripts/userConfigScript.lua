local UserConfigScript = {}

-- Script properties are defined here
UserConfigScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserConfigScript:Init()
	print("Initializing user config")
	self:GetEntity():SendToScripts("UseDb", "default", function(db)
		local records = db:Find({})
		if #records > 1 then 
			print("Something has gone very wrong. Resetting user config")
			db:DeleteMany() -- something is wrong
		end
		
		if #db:Find() == 0 then 
			db:InsertOne({})
		end
	end)
end

return UserConfigScript
