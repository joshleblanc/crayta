local DefaultConfigScript = {}

-- Script properties are defined here
DefaultConfigScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "defaultHospital", type = "string" },
}

--This function is called on the server when this entity is created
function DefaultConfigScript:Init()
	self:GetEntity().documentStoresScript:UseDb("default", function(db)
		db:UpdateOne({}, {
			_setOnInsert = {
				lastHospital = self.properties.defaultHospital
			}
		}, { upsert = true })
	end)
end

function DefaultConfigScript:UpdateLastHospital(newHospital)
	assert(#newHospital > 0, "Tried to update last hospital without a new hospital value")

	self:GetEntity().documentStoresScript:UseDb("default", function(db)
		db:UpdateOne({}, {
			_set = {
				lastHospital = newHospital
			}
		})
	end)
end

return DefaultConfigScript
