local FixMonstersScript = {}

-- Script properties are defined here
FixMonstersScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function FixMonstersScript:Init()
	self:GetEntity():SendToScripts("UseDb", "monsters", function(db)
		db:DeleteOne({ _id = 1 })
	end)
end

return FixMonstersScript
