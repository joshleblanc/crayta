local AutomatonTrailScript = {}

-- Script properties are defined here
AutomatonTrailScript.Properties = {
	-- Example property
	{ name = "defaultPlayerTrail", type = "entity" },
	{ name = "topPlayerTrail", type = "entity" }
}

--This function is called on the server when this entity is created
function AutomatonTrailScript:Init()
	self:GetEntity():GetParent():GetUser():GetLeaderboardValue("most-wins", function(score, rank) 
		print("Trail initialized, rank: {1}", rank)
		if score > 0 and rank <= 10 then
			self.properties.defaultPlayerTrail.active = false
			self.properties.topPlayerTrail.active = true
		else
			self.properties.defaultPlayerTrail.active = true
			self.properties.topPlayerTrail.active = false
		end
	end)
end

return AutomatonTrailScript
