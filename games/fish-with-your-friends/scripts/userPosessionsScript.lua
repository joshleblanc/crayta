local UserPosessionsScript = {}

-- Script properties are defined here
UserPosessionsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserPosessionsScript:Init()
	self.posessions = self:GetEntity():FindAllScripts("userPosessionScript")
	self.posessionMap = {}
	for _, p in ipairs(self.posessions) do 
		self.posessionMap[p.properties.id] = p
	end
end

function UserPosessionsScript:HandlePlayerSpawn(player)
	for _, p in ipairs(self.posessions) do 
		p:HandlePlayerSpawn(player)
	end
end

function UserPosessionsScript:FindActive(id)
	return self.posessionMap[id]:ActivePosession()
end

function UserPosessionsScript:ForEachPosession(cb)
	for _, p in ipairs(self.posessions) do 
		cb(p)
	end
end

return UserPosessionsScript
