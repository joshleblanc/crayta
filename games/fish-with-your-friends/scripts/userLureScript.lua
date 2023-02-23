local UserLureScript = {}

-- Script properties are defined here
UserLureScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "defaultLure", type = "template" }
}

--This function is called on the server when this entity is created
function UserLureScript:Init()
	self.db = self:GetEntity().documentStoresScript
	
	self:Schedule(function()
		self.db:WaitForData()
		
		local defaultLure = self.properties.defaultLure:GetName()
		
		local data = self.db:UpdateOne({}, { 
			_addToSet = {
				ownedLures = defaultLure
			},
		}, { upsert = true })
		
		if not data.activeLure then 	
			self.db:UpdateOne({}, {
				_set = {
					activeLure = defaultLure
				}
			})
		end
	end)
end

function UserLureScript:ActiveLure()
	return self.db:FindOne().activeLure
end

function UserLureScript:GetFishingPower()
	local lureId = self:ActiveLure()
	local lure = Template.Find(lureId)
	return lure:FindScriptProperty("fishingPower")
end

return UserLureScript
