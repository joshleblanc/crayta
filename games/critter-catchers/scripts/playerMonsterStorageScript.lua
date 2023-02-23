local PlayerMonsterStorageScript = {}

-- Script properties are defined here
PlayerMonsterStorageScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerMonsterStorageScript:Init()
end

function PlayerMonsterStorageScript:LocalInit()
	self.widget = self:GetEntity().playerMonsterStorageWidget
	self.widget.visible = false
	
	self.c = self:GetEntity():FindScript("playerMonstersControllerScript", true)
	self.cache = GetWorld():FindScript("entityCacheScript")
end

function PlayerMonsterStorageScript:ShowStorage() 
	if IsServer() then 
		self:SendToLocal("ShowStorage")
		return
	end
	
	self.page = 0
	self.pageSize = 6
	
	self:UpdateWidget()
	self.widget.visible = true
	self:GetEntity().cMenuScript:HideBar()
end

function PlayerMonsterStorageScript:CloseStorage()
	self:CommitChanges()
	self.widget.visible = false
	self:GetEntity().cMenuScript:ShowBar()
end

function PlayerMonsterStorageScript:CommitChanges()
	self.c:InitializeParty()
end

function PlayerMonsterStorageScript:SwapMonsters(a, b)
	print("Swapping monsters", a, b)
	local storageMon = self:FindMonster(a)
	local partyMon = self:FindMonster(b)
	
	self:GetEntity():GetUser():SendToScripts("UseDb", "monsters", function(db)
		local docA = db:FindOne({ index = a })
		local docB = db:FindOne({ index = b })
		
		
		db:UpdateOne({ _id = docA._id }, {
			_set = {
				index = b
			}
		})
		
		db:UpdateOne({ _id = docB._id }, {
			_set = {
				index = a
			}
		})
		
		self:UpdateWidget()
	end)
end

function PlayerMonsterStorageScript:FindMonster(index)
	local monsters = self.c:GetMonsters()

	for _, mon in ipairs(monsters) do 
		if mon.index == index then 
			return mon
		end
	end
end

function PlayerMonsterStorageScript:UpdateWidget()
	local monsters = self.c:GetMonsters()
	
	self:GetEntity():GetUser():SendToScripts("UseDb", "monsters", function(db)
		local party = db:Find({}, {
			sort = { index = 1 },
			limit = 6
		})
		
		local partyData = {}
		for _, p in ipairs(party) do 
			local mon = self.cache:FindEntityByTemplate(p.templateName)
			mon.monsterScript:Load(p)
			
			table.insert(partyData, mon.monsterScript:ForWidget())
		end
		
		self.widget.js.data.party = partyData
		
		local monsters = db:Find({}, {
			sort = { index = 1 },
			skip = 6 + (self.pageSize * self.page),
			limit = self.pageSize
		})
		
		local monsterData = {}
		
		for _, monster in ipairs(monsters) do 
			local mon = self.cache:FindEntityByTemplate(monster.templateName)
			mon.monsterScript:Load(monster)
			table.insert(monsterData, mon.monsterScript:ForWidget())
		end
		
		self.widget.js.data.monsters = monsterData
		self.widget.js.data.selectedIndex = nil
	end)
end

function PlayerMonsterStorageScript:NumPages()
	return math.max(1, math.ceil((#self.c:GetMonsters() - 6) / self.pageSize))
end

function PlayerMonsterStorageScript:StorageNextPage()
	self.page = math.min(self:NumPages() - 1, self.page + 1)
	self:UpdateWidget()
end

function PlayerMonsterStorageScript:StoragePrevPage()
	self.page = math.max(0, self.page - 1)
	self:UpdateWidget()
end

return PlayerMonsterStorageScript
