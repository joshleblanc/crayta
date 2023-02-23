local GameStorageControllerScript = {}

-- Script properties are defined here
GameStorageControllerScript.Properties = {
	-- Example property
	{ name = "onUpdate", type = "event" }
}

--This function is called on the server when this entity is created

GameStorageControllerScript.Keys = {
	"team-1-players", "team-2-players",
	"total-players",
	"1-quests-completed", "2-quests-completed",
	"1-wins", "2-wins",
	"1-wood-mined", "2-wood-mined",
	"1-stone-mined", "2-stone-mined",
	"1-wood", "2-wood",
	"1-stone", "2-stone",
	"1-gold", "2-gold",
	"1-Food Shop-wood", "2-Food Shop-wood",
	"1-Food Shop-stone", "2-Food Shop-stone",
	"1-Fish Shop-wood", "2-Fish Shop-wood",
	"1-Fish Shop-stone", "2-Fish Shop-stone",
}

for _, v in ipairs(GameStorageControllerScript.Keys) do
	table.insert(GameStorageControllerScript.Properties, { name = v, type = "number", editable = false }) 
end

function GameStorageControllerScript:Init()
	self:Schedule(function()
		while true do
			for _, v in ipairs(GameStorageControllerScript.Keys) do
				local done = false
				GameStorage.GetCounter(v, function(value)
					if self.properties[v] ~= value then
						self.properties.onUpdate:Send(v, value)
						self.properties[v] = value
					end
				end)
			end
			Wait(1)
		end
	end)
end

function GameStorageControllerScript:Update(key, value)
	if not IsServer() then
		self:SendToServer("Update", key, value)
		return
	end
	
	-- try to optimistically set the property
	self.properties[key] = self.properties[key] + value
	GameStorage.UpdateCounter(key, value, function(total)
		self.properties.onUpdate:Send(key, total)
		self.properties[key] = total
	end)
end

function GameStorageControllerScript:Get(key, ...)
	return self.properties[FormatString(key, ...)]
end

return GameStorageControllerScript
