local PlayerMonstersControllerScript = {}

-- Script properties are defined here
PlayerMonstersControllerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onMonsterAdded", type = "event" },
}

function PlayerMonstersControllerScript:Init()
	self:InitializeParty()
end

function PlayerMonstersControllerScript:ClearPartyEntities()
	local children = self:GetEntity():GetChildren()
	
	for _, child in ipairs(children) do 
		child:Destroy()
	end
end

function PlayerMonstersControllerScript:InitializeParty()
	if not IsServer() then 
		self:SendToServer("InitializeParty")
		return
	end
	
	local c = self:GetCache()
	
	self.index = 1
	self:ClearPartyEntities()
	self:GetEntity():GetParent():GetUser():SendToScripts("UseDb", "monsters", function(db)
		local docs = db:Find({}, {
			sort = {
				index = 1
			}
		})
	
		self:Schedule(function()
			for _, doc in ipairs(docs) do 
				Wait()
				
				if self.index <= 6 then 
					local mon = c:FindEntityByTemplate(doc.templateName)
					local dup = mon:Clone()
					
					dup:AttachTo(self:GetEntity())
					dup.monsterScript:Load(doc)
					dup.monsterScript.properties.index = self.index
				end
				
				db:UpdateOne({ _id = doc._id }, {
					_set = {
						index = self.index
					}
				})
				
				self.index = self.index + 1
			end
		end)
	end)
end

function PlayerMonstersControllerScript:LocalInit()
	self:Schedule(function()
		while true do 
			Wait(60)
			self:Save()
			
			--[[
			self:GetEntity():GetParent():GetUser():SendToScripts("UseDb", "monsters", function(db)
				local docs = db:Find({}, {
					sort = {
						index = 1
					}
				})
			
				
				for _, doc in ipairs(docs) do 
					print(doc.id, doc.index)
				end
				print("----")
				
			end)
			]]--
		end
	end)
end

function PlayerMonstersControllerScript:RemoveMonster(monster)
	if not IsServer() then 
		self:SendToServer("RemoveMonster", monster)
		return
	end
	
	self:GetEntity():GetParent():GetUser():SendToScripts("UseDb", "monsters", function(db)
		db:DeleteOne({ _id = monster.properties.docId })
		
		monster:GetEntity():Destroy()
	end)
end

function PlayerMonstersControllerScript:AddMonster(monster, hp, level, index)
	if not IsServer() then 
		self:SendToServer("AddMonster", monster, hp or monster.properties.hp, level or monster:GetLevel(), index)
		return
	end
	
	print("Sending onMonsterAdded event", monster:GetEntity():GetTemplate())
	self.properties.onMonsterAdded:Send(monster:GetEntity():GetTemplate())
	
	index = index or self.index
	
	self:GetEntity():GetParent():GetUser():SendToScripts("UseDb", "monsters", function(db)
		local dup = monster:GetEntity():Clone()
		dup.monsterScript.properties.index = index
		dup.monsterScript.properties.hp = hp
		dup.monsterScript:SetLevel(level)
		
		local moves = dup.monsterScript:GetMoves()
		local applicableMoves = {}
		local cnt = 0
		
		table.sort(moves, function(a,b)
			return a.properties.minLevel > b.properties.minLevel
		end)
		
		for id, move in pairs(moves) do 
			if move.properties.minLevel <= level and cnt < 4 then 
				print("Equipping move", move.properties.id)
				move.properties.equipped = true
			else
				move.properties.equipped = false
			end
		end
		
		print("Addding monster", dup.monsterScript:GetLevel(), dup.monsterScript.properties.index) 
		
		if #self:GetParty() >= 6 or index then 
			dup.monsterScript:ResetHp()
		end

		db:InsertOne(dup.monsterScript:ToTable())
		
		if #self:GetParty() < 6 or index <= 6 then 
			dup:AttachTo(self:GetEntity())
		else
			dup:Destroy()
		end
		
		if not index then 
			self.index = self.index + 1
		end
	end)
end

function PlayerMonstersControllerScript:Save()
	if IsServer() then 
		self:SendToLocal("Save")
		return
	end
	
	print("SAVING")
	
	local monsters = self:GetParty()
	
	self:GetEntity():GetParent():GetUser():SendToScripts("UseDb", "monsters", function(db)
		local docs = db:Find()
	
		for _, mon in ipairs(monsters) do 
			db:UpdateOne({ _id = mon.properties.docId }, {
				_set = mon:ToTable()
			})
		end
	end)
end

function PlayerMonstersControllerScript:GetMonsters()
	print("Getting all monsters")
	local db = self:GetEntity():GetParent():GetUser().documentStoresScript:GetDb("monsters")
	
	return db:Find({}, { 
		sort = { 
			index = 1 
		} 
	})
end

function PlayerMonstersControllerScript:GetParty()
	local party = self:GetEntity():FindAllScripts("monsterScript")

	table.sort(party, function(a,b)
		return a.properties.index < b.properties.index
	end)

	return party
end

function PlayerMonstersControllerScript:GetCache()
	if not self.cache then 
		self.cache = GetWorld():FindScript("entityCacheScript")
	end
	
	return self.cache
end

return PlayerMonstersControllerScript
