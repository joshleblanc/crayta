local BillboardScript = {}

-- Script properties are defined here
BillboardScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "team", type = "number" },
	{ name = "gameStorageController", type = "entity" }
}

--This function is called on the server when this entity is created
function BillboardScript:Init()
	local team = self.properties.team
	self.mappings = {}
	self.mappings[FormatString("team-{1}-players", team)] = "teamPlayers"
	self.mappings["total-players"] = "totalPlayers"
	self.mappings[FormatString("{1}-quests-completed", team)] = "questsCompleted"
	self.mappings[FormatString("{1}-wins", team)] = "wins"
	self.mappings[FormatString("{1}-wood-mined", team)] = "treesChopped"
	self.mappings[FormatString("{1}-stone-mined", team)] = "rocksSmashed"
end

function BillboardScript:HandleStorageUpdate(key, value)
	if self.mappings[key] then
		self:UpdateWidget(self.mappings[key], value)
	end
end

function BillboardScript:ClientInit()
	self.widget = self:GetEntity().billboardWidget
	
	local team = self.properties.team
	local p = self.properties.gameStorageController.gameStorageControllerScript
	
	if team == 1 then
		self.widget.js.data.team = "East Craytasia"
	else
		self.widget.js.data.team = "West Craytasia"
	end
	self.widget.js.data.teamPlayers = p:Get("team-{1}-players", team)
	self.widget.js.data.totalPlayers = p:Get("total-players")
	self.widget.js.data.questsCompleted = p:Get("{1}-quests-completed", team)
	self.widget.js.data.wins = p:Get("{1}-wins", team)
	self.widget.js.data.treesChopped = p:Get("{1}-wood-mined", team)
	self.widget.js.data.rocksSmashed = p:Get("{1}-stone-mined", team)
end

function BillboardScript:UpdateWidget(key, value)
	if IsServer() then
		self:SendToAllClients("UpdateWidget", key, value)
		return
	end

	self.widget.js.data[key] = value
end

return BillboardScript
