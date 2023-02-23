local OutOfBoundsTriggerScript = {}

-- Script properties are defined here
OutOfBoundsTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function OutOfBoundsTriggerScript:Init()
	self.players = {}
end

function OutOfBoundsTriggerScript:OnTriggerEnter(player)
	table.insert(self.players, player)
end

function OutOfBoundsTriggerScript:OnTriggerExit(player)
	local players = { unpack(self.players) }
	for i, p in ipairs(self.players) do
		if p == player then
			table.remove(players, i)
		end
	end
	self.players = players
end

function OutOfBoundsTriggerScript:RemovePlayers(locator)
	for _, player in ipairs(self.players) do
		player:SetPosition(locator:GetPosition())
	end
	self.players = {}
end

return OutOfBoundsTriggerScript
