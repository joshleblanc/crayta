local HeroQuartersScript = {}

-- Script properties are defined here
HeroQuartersScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "floor", type = "number", default = 1, editable = false },
	{ name = "emptyRoomTemplate", type = "template" },
	{ name = "roomLocations", type = "entity", container = "array" }
}

function HeroQuartersScript:HandleLocationSpawn(user)
	local heroes = user.userHeroesScript:GetHeroes()
	local data = {}
	
	for i=1,#self.properties.roomLocations do 
		local hero = heroes[i]
		local position = self.properties.roomLocations[i]
		if not hero then return end  -- TODO: spawn an empty room instead 
		
		local heroTemplate = GetWorld():FindTemplate(hero.templateName)
		local roomTemplate = heroTemplate:FindScriptProperty("roomTemplate")
		
		local room = GetWorld():Spawn(roomTemplate, Vector.Zero, Rotation.Zero)
		room:AttachTo(position)
		
		self:Schedule(function() 
			Wait()
			room:SendToScripts("AssignHero", hero)
		end)
		
	end
end

return HeroQuartersScript
