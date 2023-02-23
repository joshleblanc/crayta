local HeroSelectScript = {}

-- Script properties are defined here
HeroSelectScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "npcStartPosition", type = "entity" },
	{ name = "npcStandPosition", type = "entity" },
	{ name = "npcEndPosition", type = "entity" },
	{ name = "camera", type = "entity" },
	{ name = "door", type = "entity" }
}

function HeroSelectScript:SetOwner(user)
	print("Running hero select script set owner")
	user.userHeroSelectScript:SetHeroSelect(self:GetEntity())
end

return HeroSelectScript
