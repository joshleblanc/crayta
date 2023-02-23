local PlayerCheaterGameScript = {}

-- Script properties are defined here
PlayerCheaterGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "isSafe", type = "boolean", default = true },
	{ name = "beingWatched", type = "boolean", default = false },
	{ name = "watchedColorGrading", type = "colorgradingasset"},
	{ name = "defaultColorGrading", type = "colorgradingasset"}
	
}

function PlayerCheaterGameScript:Init()
	self.cheaterGameScript = GetWorld():FindScript("cheaterGameScript")
	self:Schedule(function()
		self:GetEntity():GetUser():SetCamera(self.cheaterGameScript.properties.camera)
	end)
end

function PlayerCheaterGameScript:LocalOnTick()
	if self.properties.beingWatched and self:GetEntity():IsAlive() then
		GetWorld().colorGrading = self.properties.watchedColorGrading
	else
		GetWorld().colorGrading = self.properties.defaultColorGrading
	end
end

function PlayerCheaterGameScript:OnDestroy()
	GetWorld().colorGrading = self.properties.defaultColorGrading
end



return PlayerCheaterGameScript
