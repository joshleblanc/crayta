local PalaceLocationScript = {}

-- Script properties are defined here
PalaceLocationScript.Properties = {
	-- Example property
	{ name = "team", type = "number", options = { 1, 2 }, default = 1 } 
}

--This function is called on the server when this entity is created
function PalaceLocationScript:Init()
	if self.properties.team == 1 then
		self.title = "East Craytasia"
	else
		self.title = "West Craytasia"
	end
end

function PalaceLocationScript:OnTriggerEnter(player)
	if not player:IsA(Character) then return end
	
	Leaderboards.GetTopValues(FormatString("{1}-wealth", self.properties.team), 1, function(results) 
		for _, v in ipairs(results) do
			print(v.name)
			if v.rank == 1 then
				player:GetUser():SendToScripts("ShowLocation", { label = FormatString("{1}'s Palace", v.name), title = self.title })
			end
		end
	end)
end

return PalaceLocationScript
