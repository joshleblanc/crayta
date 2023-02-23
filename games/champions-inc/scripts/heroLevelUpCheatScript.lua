local HeroLevelUpCheatScript = {}

-- Script properties are defined here
HeroLevelUpCheatScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function HeroLevelUpCheatScript:Init()
end

function HeroLevelUpCheatScript:LevelUpSelectedHero()
	self:GetEntity().documentStoresScript:UseDb("heroes", function(db)
		db:UpdateMany({}, {
			_inc = {
				xp = 10000
			}
		})
		
	end)
end

return HeroLevelUpCheatScript
