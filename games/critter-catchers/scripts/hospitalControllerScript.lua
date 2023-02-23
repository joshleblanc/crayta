local HospitalControllerScript = {}

-- Script properties are defined here
HospitalControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function HospitalControllerScript:Init()
	self.entries = self:GetEntity():FindAllScripts("hospitalEntryScript")
end

function HospitalControllerScript:ClientInit()
	self:Init()
end

function HospitalControllerScript:FindSpawn(id)
	print("Finding hospital spawn", id)
	for _, entry in ipairs(self.entries) do
		print(entry.properties.id, id)
		if entry.properties.id == id then 
			return entry
		end	
	end
end

return HospitalControllerScript
