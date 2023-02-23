local KillsTracker = {}

-- Script properties are defined here
KillsTracker.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "killsSinceSpawn", type = "number", default = 0, editable = false, },
}

--This function is called on the server when this entity is created
function KillsTracker:Init()
end

function KillsTracker:OnBulletFired(weapon, target, damage, isTarget, crit, isFatal, pos)
	
	--self:GetEntity():GetUser():SendToScripts("OnBulletFired", weapon, target, damage, isTarget, crit, isFatal, pos)
	print("Bullet fired")
	-- challenge event for kill, with crit and killsSinceSpawn
	if isFatal then
		self.properties.killsSinceSpawn = self.properties.killsSinceSpawn + 1
		self:GetEntity():GetUser():SendChallengeEvent("kill-player", {crit = crit, killsSinceSpawn = self.properties.killsSinceSpawn, weapon = weapon:GetTemplate() and weapon:GetTemplate():GetName() or nil})
	end
	
end

return KillsTracker
