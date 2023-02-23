local VictoryScript = {}

-- Script properties are defined here
VictoryScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "payload", type = "entity" }
}

--This function is called on the server when this entity is created
function VictoryScript:Init()
	self.game = GetWorld():FindScript("gameScript")
end

function VictoryScript:Team1Win(track, transform)
	if transform:GetEntity() ~= self.properties.payload then return end 

	self.game:SetTeamScore(1, 50)
	self.game:EndPlay()
end

function VictoryScript:Team2Win(track, transform)
	if transform:GetEntity() ~= self.properties.payload then return end 
	
	self.game:SetTeamScore(2, 50)
	self.game:EndPlay()
end

return VictoryScript
