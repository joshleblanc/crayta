local DocumentStoresScript = {}

DocumentStoresScript.Properties = {}

function DocumentStoresScript:Init()
	self:InitDbs()
end

function DocumentStoresScript:LocalInit()
	self:InitDbs()
end

function DocumentStoresScript:Clear()
	for key, _ in pairs(self.root) do 
		self[key]:DeleteMany()
	end
end

function DocumentStoresScript:InitDbs()
	self.stores = {}
	for _, store in ipairs(self:GetEntity():FindAllScripts("documentStoreScript")) do 
		self[store.properties.id] = store
		table.insert(self.stores, store)
		if IsServer() then 
			self.root = self.root or self:GetSaveData()
			
			local id = store.properties.id
			
			if store.properties.useVersions then 
				self.root[id] = nil
				for i=1, store.properties.version - 1 do 
					self.root[id .. "_" .. i] = nil
				end
				id = id .. "_" .. store.properties.version
			end
			
			self.root[id] = self.root[id] or {}
			
			local data = self.root[id]
			
			store:InitSaveData(data)
			
			for k, v in pairs(data) do 	
				store:SendToLocal("InitSaveDataPart", k, v)
			end
			
			print("Initialized: ", store.properties.id, store.data)
			
			--[[ Replaced with InitSaveDataPart due to sending too much data to client
			store:InitSaveData(self.root[store.properties.id])
			store:SendToLocal("InitSaveData", self.root[store.properties.id])
			--]]
		end
	end
	
	self.ready = true
end

function DocumentStoresScript:PersistData()
	if not IsServer() then 
		self:SendToServer("PersistData")
		return
	end
	self:SetSaveData(self.root)
end

function DocumentStoresScript:GetDb(db)
	if not self.ready then 
		self:InitDbs()
	end
	
	return self[db]
end

function DocumentStoresScript:UseDb(db, cb)
	self:Schedule(function()
		self:WaitForReady()
		self[db]:WaitForData()
		
		cb(self[db])
	end)
end

function DocumentStoresScript:WaitForReady()
	while not self.ready do 
		Wait()
	end
end

--[[
	Singleton proxy methods
]]--
function DocumentStoresScript:_ProxyMethod(method, ...)
	return self.stores[1][method](self.stores[1], ...)
end

function DocumentStoresScript:WaitForData()
	return self:_ProxyMethod("WaitForData")
end

function DocumentStoresScript:Find(...)
	return self:_ProxyMethod("Find", ...)
end

function DocumentStoresScript:FindOne(...)
	return self:_ProxyMethod("FindOne", ...)
end

function DocumentStoresScript:InsertOne(...)
	return self:_ProxyMethod("InsertOne", ...)
end

function DocumentStoresScript:InsertMany(...)
	return self:_ProxyMethod("InsertMany", ...)
end

function DocumentStoresScript:UpdateMany(...)
	return self:_ProxyMethod("UpdateMany", ...)
end

function DocumentStoresScript:UpdateOne(...)
	return self:_ProxyMethod("UpdateOne", ...)
end

function DocumentStoresScript:ReplaceOne(...)
	return self:_ProxyMethod("ReplaceOne", ...)
end

function DocumentStoresScript:DeleteOne(...)
	return self:_ProxyMethod("DeleteOne", ...)
end

function DocumentStoresScript:DeleteMany(...)
	return self:_ProxyMethod("DeleteMany", ...)
end

return DocumentStoresScript
