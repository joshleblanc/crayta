local RetroactiveHeroAquisitionQuestCompletionScript = {}

-- Script properties are defined here
RetroactiveHeroAquisitionQuestCompletionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function RetroactiveHeroAquisitionQuestCompletionScript:Init()
	local db = self:GetEntity().documentStoresScript
	self:Schedule(function()
		self:GetEntity().documentStoresScript:WaitForReady()
		
		db:UseDb("heroes", function(heroes)
			local allHeroes = heroes:Find()
			for _, hero in ipairs(allHeroes) do 
				self:GetEntity():SendToScripts("HandleRetroactiveHeroAquisition", GetWorld():FindTemplate(hero.templateName))
			end
		end)
	end)
end

return RetroactiveHeroAquisitionQuestCompletionScript
