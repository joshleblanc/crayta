local MagnetFieldScript = {}

-- Script properties are defined here
MagnetFieldScript.Properties = {
	-- Example property
	{name = "slowerSpeed", type = "number", default = .5},
	{name = "normalSpeed", type = "number", default = 1.5},
}

--This function is called on the server when this entity is created
function MagnetFieldScript:Init()
	self.players = {}
end

function MagnetFieldScript:OnTick()
	
	for k, v in ipairs(self.players) do
		local distance = Vector.Distance(self:GetEntity():GetPosition(), v:GetPosition())
		local adjustment = distance / 1000
		v.speedMultiplier = adjustment
		print(distance)
		
	end
end

function MagnetFieldScript:OnTriggerEnter(player)
	table.insert(self.players, player)
end

function MagnetFieldScript:OnTriggerExit(player)
	local indexToRemove = 0
	for k, v in ipairs(self.players) do
		if v == player then
			indexToRemove = k
		end
	end
	if indexToRemove > 0 then
		table.remove(self.players, indexToRemove)
	end
	player.speedMultiplier = self.properties.normalSpeed
end


return MagnetFieldScript
