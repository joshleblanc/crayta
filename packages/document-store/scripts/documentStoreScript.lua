
-- https://gist.github.com/jrus/3197011
local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local DocumentStoreScript = {}

-- Script properties are defined here
DocumentStoreScript.Properties = {
	-- Example property
	{ name = "id", type = "string", default = "default" },
	{ name = "useVersions", type = "boolean", default = false },
	{ name = "version", type = "number", default = 1, visibleIf=function(p) return p.useVersions end },
}

--This function is called on the server when this entity is created
function DocumentStoreScript:Init()
	--[[
	self.root = self:GetSaveData()
	
	if #self.properties.id > 0 then 
		self.root[self.properties.id] = self.root[self.properties.id] or {}
	 	self.data = self.root[self.properties.id]
	else 
		self.data = self.root
	end
	
	self:SendToLocal("InitSaveData", self.root)
	--]]
end

function DocumentStoreScript:ClientInit()
	self.data = self.data or {}
end

function DocumentStoreScript:WaitForData()
	while not self.data do 
		Wait()
	end
end

function DocumentStoreScript:InitSaveDataPart(key, data)
	self.data = self.data or {}
	self.data[key] = data
end

function DocumentStoreScript:InitSaveData(data)
	self.data = data
	--[[
	self.root = data
	if #self.properties.id > 0 then 
		self.root[self.properties.id] = self.root[self.properties.id] or {}
	 	self.data = self.root[self.properties.id]
	else 
		self.data = self.root
	end
	]]--
end

--[[
	Find
--]]
function DocumentStoreScript:Find(query, projection)
	return self:Query(query, projection)
end

--[[
	FindOne
--]]
function DocumentStoreScript:FindOne(query, projections)
	return self:QueryOne(query, projections)
end

--[[
	InsertOne
]]--
function DocumentStoreScript:InsertOne(data)
	local id = data._id or uuid()
	
	data._id = id

	if IsServer() then 
		print("(Server) Inserting one: ", id)
		self:ServerInsertOne(id, data)
		self:SendToLocal("LocalInsertOne", id, data)
	else 
		print("(Local) Inserting one: ", id)
		self:LocalInsertOne(id, data)
		self:SendToServer("ServerInsertOne", id, data)
	end
	
	self:PersistData()
	
	GetWorld():BroadcastToScripts("OnRecordInserted", self.properties.id, data)
	self:GetEntity():SendToScripts("OnMyRecordInserted", self.properties.id, data)
	
	return data
end

function DocumentStoreScript:ServerInsertOne(id, data)
	print("Server insert one", id, data)
	self.data[id] = data
end

function DocumentStoreScript:LocalInsertOne(id, data)
	print("Local Insert One", id, data)
	self.data[id] = data
end

--[[
	InsertMany
]]--
function DocumentStoreScript:InsertMany(data)
	for _, v in ipairs(data) do
		self:InsertOne(v)
	end
	
	return data
end

--[[
	UpdateMany
--]]
function DocumentStoreScript:UpdateMany(query, operators, options)
	options = options or {}
	
	local records = self:Query(query)
	
	local newRecords = {}
	for _, v in ipairs(records) do 
		local newRecord = self:UpdateRecord(v, query, operators, options)
		table.insert(newRecords, newRecord)
	end
	
	self:PersistData()
	
	return newRecords
end

--[[
	UpdateOne 
--]]
function DocumentStoreScript:UpdateOne(query, operators, options)
	options = options or {}
	
	local record = self:QueryOne(query)
	
	if not record and not options.upsert then return end
	
	record = self:UpdateRecord(record, query, operators, options)
	
	self:PersistData()
	
	return record
end

function DocumentStoreScript:ServerUpdateOne(id, record)
	self.data[id] = record
end

function DocumentStoreScript:LocalUpdateOne(id, record)
	if not self.data then 
		return
	end
	
	self.data[id] = record
end

function DocumentStoreScript:BuildRecordFromQuery(query)
	local record = {}
	if type(query) == "table" then 
		for k, v in pairs(query) do 
			if string.sub(k, 1, 1) == "_" then 
				--return nil
			else
				record[k] = self:BuildRecordFromQuery(v)
			end
		end
		return record
	else
		return query
	end
end

function DocumentStoreScript:UpdateRecord(record, query, operators, options)

	local isUpdateDocument = true 
    for k, v in pairs(operators) do 
    	if type(v) == "table" then 
    		isUpdateDocument = false
    	end
    end
    
    -- if there's no update operators, replace the document with the new one
    if isUpdateDocument then 
    	local id = record and record._id
    	record = operators
    	record._id = id
    else
    	-- if there's no record and we need to upsert, we need to build the original document
    	-- from the query
    	options._isNew = not record
    	
    	if not record and options.upsert then 
    		record = self:BuildRecordFromQuery(query, record)
    		--print("Upserting new record, building from scratch", self:GetEntity():SendToScripts("PrintTable", record))
    	end
    	
    	for k, v in pairs(operators) do 
			self:ProcessOperator(k, v, record, options)
		end
    end
    
    if options.upsert and not record._id then 
    	record._id = query._id or uuid()
    end

	if IsServer() then 
		self:ServerUpdateOne(record._id, record)
		self:SendToLocal("LocalUpdateOne", record._id, record)
	else 
		self:LocalUpdateOne(record._id, record)
		self:SendToServer("ServerUpdateOne", record._id, record)
	end
	
	GetWorld():BroadcastToScripts("OnRecordUpdated", self.properties.id, record)
	self:GetEntity():SendToScripts("OnMyRecordUpdated", self.properties.id, record)
	
	return record
end


--[[
	ReplaceOne
]]--
function DocumentStoreScript:ReplaceOne(query, data)
	local record = self:QueryOne(query)
	
	if not record then return end
	
	data._id = record._id
	
	if IsServer() then 
		self:ServerUpdateOne(record._id, data)
		self:SendToLocal("LocalUpdateOne", record._id, data)
	else 
		self:LocalUpdateOne(record._id, data)
		self:SendToServer("ServerUpdateOne", record._id, data)
	end
	
	self:PersistData()
end

--[[
	DeleteOne
]]--
function DocumentStoreScript:DeleteOne(query)
	local record = self:QueryOne(query)
	
	if not record then return end 
	
	self:ProcessDelete(record)
	
	self:PersistData()
	
	return record
end

function DocumentStoreScript:ProcessDelete(record)
	if IsServer() then 
		self:ServerDeleteOne(record._id, data)
		self:SendToLocal("LocalDeleteOne", record._id)
	else 
		self:LocalDeleteOne(record._id, data)
		self:SendToServer("ServerDeleteOne", record._id)
	end
	
	GetWorld():BroadcastToScripts("OnRecordDeleted", self.properties.id, record)
	self:GetEntity():SendToScripts("OnMyRecordDeleted", self.properties.id, record)
end

function DocumentStoreScript:LocalDeleteOne(id)
	self.data[id] = nil
end

function DocumentStoreScript:ServerDeleteOne(id)
	self.data[id] = nil
end

--[[
	DeleteMany
]]--
function DocumentStoreScript:DeleteMany(query)
	local records = self:Query(query)
	
	for _, record in ipairs(records) do 
		self:ProcessDelete(record)
	end
	
	self:PersistData()
	
	return records
end

---

--[[
	Operators
]]--

function _arrayOps(self, method, arrayOperator, key, value, record, options)
	if arrayOperator == "_" then 
		method(self, 1, value, record)
	elseif arrayOperator == "_[]" then
		for idx, _ in ipairs(value) do 
			method(self, idx, value, record)
		end
	else 
		--[[
			Handle the arrayFilters option with the _[<identifer>] operator
			First thing to know is that filters is an array.
			Second thing to know is that every element of the filters array is an object
			Third thing to know is that each of those objects has a key that can match <identifier>
			
			Following that, the logic is as follows:
				1. Iterate each filter
				2. For each filter, iterate the conditions
					2a. Check if the filter condition matches <identifier>
				3. If we have a match, iterate every value of the array
				4. 
					4a. For each value of the array, if the condition is a table, run it through the ProcessSelectors methods
					4b. If it's not a table, just replace it wholesale
		--]]
		local filters = options.arrayFilters or {}
		local identifier = string.match(arrayOperator, "_%[?(%w*)%]?")
		
		for _, filter in ipairs(filters) do -- filters is an array, filter is an object
			for filterIdentifier, condition in pairs(filter) do  -- for each filter, check that the identifier matches
				if filterIdentifier == identifier then 
					for idx, _ in ipairs(record) do --if we have a match, run the condition against every element in the array
						if type(condition) == "table" then 
							if self:ProcessSelectors(record, idx, condition) then
								record[idx] = value
							end
						else 
							record[idx] = value
						end
					end
				end
			end
		end
	end
end

function _set(self, key, value, record)
	record[key] = value
end

function _inc(self, key, value, record)
	record[key] = record[key] or 0
	record[key] = record[key] + value
end

function _min(self, key, value, record)
	if value < record[key] then 
		record[key] = value
	end
end

function _max(self, key, value, record)
	if value > record[key] then 
		record[key] = value
	end
end

function _unset(self, key, value, record)
	record[key] = nil
end

function _rename(self, key, value, record)
	record[value] = record[key]
	record[key] = nil
end

function _mul(self, key, value, record)
	record[key] = record[key] * value
end

function _setOnInsert(self, key, value, record, opts)
	if opts._isNew then 
		_set(self, key, value, record)
	end
end

function hasValue(arr, value)
	for _, v in ipairs(arr) do 
		if v == value then 
			return true
		end
	end
	return false
end

function _addToSet(self, key, value, record)
	if type(value) == "table" then 
		for modifier, parameters in pairs(value) do 
			if modifier == "_each" then
				for _, parameter in ipairs(parameters) do 
					_addToSet(self, key, parameter, record)
				end
			end 
		end
	else
		if not record[key] then 
			record[key] = {}
		end
		if not hasValue(record[key], value) then 
			
			table.insert(record[key], value)
		end
	end
end

function _pop(self, key, value, record)
	if value == 1 then 
		table.remove(record[key])
	elseif value == -1 then 
		table.remove(record[key], 1)
	end
end

function _pull(self, key, value, record)
	if type(value) == "table" then 
		for idx=#record[key],1,-1 do 
			if self:ProcessSelectors(record[key], idx, value) then
				table.remove(record[key], idx)
			end
		end
	else
		for idx=#record[key],1,-1 do 
			if record[key][idx] == value then 
				table.remove(record[key], idx)
			end
		end
	end
end

function _push(self, key, value, record, opts)
	if type(value) == "table" then 
	
		-- the _position, _slice, and _sort modifiers modify the _each operator,
		-- so we need to scan for them first
		for modifier, parameter in pairs(value) do 
			if modifier == "_position" then 
				opts.position = parameter
			end
			if modifier == "_slice" then 
				opts.slice = parameter
			end
			if modifier == "_sort" then 
				opts.sort = parameter
			end
		end
		
		for modifier, parameters in pairs(value) do 
			if modifier == "_each" then
				for _, parameter in ipairs(parameters) do 
					_push(self, key, parameter, record, opts)
				end
			end 
		end
	else
		if opts.position then 
			table.insert(record[key], opts.position, value)
		else 
			table.insert(record[key], value)
		end
	end
	
	if opts.slice then 
		if opts.slice == 0 then 
			record[key] = {}
		elseif opts.slice > 0 then 
			record[key] = { unpack(record[key], 1, opts.slice) }
		else 
			local offset = #record[key] - opts.slice
			record[key] = { unpack(record[key], offset, slice) }
		end
	end
	
	if opts.sort then 
		local documentSort = type(opts.sort) == "table"
		local documentKey = nil
		local documentValue = nil
		if documentSort then 
			for k, v in pairs(opts.sort) do 
				documentKey = k
				documentValue = v
			end
		end
		table.sort(record[key], function(a,b) 
			if documentSort then 
				local aTraverse = a 
				local bTraverse = b
				for part in string.gmatch(documentKey, "([^%.]+)") do 
					aTraverse = aTraverse[part]
					bTraverse = bTraverse[part]
				end
				
				if documentValue == 1 then 
					return aTraverse < bTraverse
				elseif documentValue == -1 then
					return aTraverse > bTraverse
				end
				
			else 
				if opts.sort == 1 then 
					return a < b
				elseif opts.sort == -1 then 
					return a > b
				end
			end
		end)
	end
end

function _pullAll(self, key, value, record)
	for _, v in ipairs(value) do 
		for i=#record[key],1,-1 do 
			local el = record[key][i]
			if el == v then 
				table.remove(record[key], i)
			end 
		end
	end
end

local operatorMap = {
	_set = _set,
	_inc = _inc,
	_min = _min,
	_max = _max,
	_unset = _unset,
	_rename = _rename,
	_mul = _mul,
	_setOnInsert = _setOnInsert,
	_addToSet = _addToSet,
	_pop = _pop,
	_pull = _pull,
	_push = _push,
	_pullAll = _pullAll
}

local operatorModifiers = {
	_each = _each
}

function DocumentStoreScript:ProcessOperator(operator, fields, record, options)
	for k, v in pairs(fields) do 
		local traversal = record 
		local parts = {}
		local keys = {}
		
		for part in string.gmatch(k, "([^%.]+)") do 
			table.insert(parts, traversal)
			table.insert(keys, part)
			if traversal then 
				traversal = traversal[part]
			else
				traversal = nil
			end
			
		end
		
		local key = keys[#keys]
		local isArrayOperator = false
		local arrayOperator = nil
		
		if string.match(k, "^_%[?%w*%]?") then 
			isArrayOperator = true
			arrayOperator = key
			key = keys[#keys - 1]
		end
		
		if isArrayOperator then 
			_arrayOps(self, operatorMap[operator], arrayOperator, key, v, parts[#parts], options)
		else
			operatorMap[operator](self, key, v, parts[#parts], options)
		end
	end
end

function DocumentStoreScript:Project(projections, record)
	if projections then 
		projections._id = projections._id or true 
		local retVal = {}
		for k, v in pairs(projections) do 
			if v or v == 1 then 
				retVal[k] = record[k]
			end
		end
	else
		return record
	end
end

function DocumentStoreScript:Query(query, options)
	query = query or {}
	options = options or {}
	
	if query._id then 
		return self:ValidateRecord(query, self.data[query._id])
	end
	
	local retValue = {}
	
	if query == {} then 
		retValue = self.data
	else
		for _, v in pairs(self.data) do 
			local validatedRecord = self:ValidateRecord(query, v)
			if validatedRecord then 
				table.insert(retValue, self:Project(options.project, validatedRecord))
			end
		end
	end
	
	-- we're just kinda using projections as options now
	
	if options.sort then 
		print("Sorting...")
		table.sort(retValue, function(a,b)
			for k, v in pairs(options.sort) do 
				if v > 0 then 
					return a[k] < b[k]
				elseif v < 0 then
					return a[k] > b[k]
				end
			end
		end)
	end
	
	if options.skip then 
		local ind = 1
		while ind <= options.skip do 
			table.remove(retValue, 1)
			ind = ind + 1
		end
	end
	
	if options.limit then 
		local limitedRetVal = {}
		
		for i, v in ipairs(retValue) do 
			if i > options.limit then 
				return limitedRetVal
			end
			
			table.insert(limitedRetVal, v)
		end
	end
	
	return retValue
end

function DocumentStoreScript:QueryOne(query, projections)
	query = query or {}
	
	if query._id then 
		return self:ValidateRecord(query, self.data[query._id])
	end

	if query == {} then 
		for _, v in pairs(self.data) do 
			return v
		end
	end
	
	local retValue = {}
	
	for _, v in pairs(self.data) do 
		local validatedRecord = self:ValidateRecord(query, v)
		if validatedRecord then 
			return self:Project(projections, validatedRecord)
		end
	end
	
	return nil
end

--[[
	Selectors
--]]
function _eq(self, record, field, value) 
	return record[field] == value
end

function _gt(self, record, field, value)
	if record[field] == nil then 
		return false
	end
	
	return record[field] > value
end

function _lt(self, record, field, value)
	if record[field] == nil then 
		return false
	end
	
	return record[field] < value
end

function _gte(self, record, field, value)
	return record[field] >= value
end

function _lte(self, record, field, value)
	return record[field] <= value
end

function _ne(self, record, field, value)
	return record[field] ~= value
end

function _nin(self, record, field, value)
	for _, v in ipairs(value) do
		if v == record[field] then 
			return false
		end
	end
	return true
end

function _in(self, record, field, value)
	for _, v in ipairs(value) do
		if v == record[field] then 
			return true
		end
	end
	return false
end

function _not(self, record, field, value)
	-- Remove the _not and build a normal query, but negate the return value
	local query = {}
	query[field] = value
	return not self:ValidateRecord(query, record)
end

function _exists(self, record, field, value)
	if value and record[field] ~= nil then 
		return true
	elseif not value and record[field] == nil then 
		return true
	else
		return false
	end
end

function _type(self, record, field, value) 
	local fieldType = type(record[field])
	
	if type(value) == "table" then 
		for _, v in ipairs(value) do 
			if fieldType == v then 
				return true
			end
		end
		return false
	else
		return fieldType == value
	end
end

function _mod(self, record, field, value) 
	local divisor = value[1]
	local remainder = value[2]
	return record[field] % divisor == remainder
end

function _all(self, record, field, value) 
	local fieldValue = record[field]
	
	for _, v in ipairs(value) do 
		if not hasValue(fieldValue, v) then 
			return false
		end
	end
	
	return true
end

function _elemMatch(self, record, field, value)
	local fieldValue = record[field]
	
	for index, _ in ipairs(fieldValue) do 
		if self:ProcessSelectors(fieldValue, index, value) then 
			return true
		end
	end
	
	return false
end

function _size(self, record, field, value)
	local fieldValue = record[field]
	
	return #fieldValue == value
end

function _or(self, record, operations)
	for k, expr in pairs(operations) do 
		if self:ValidateRecord(expr, record) then
			return true
		end
	end

	return false
end


function _and(self, record, operations)
	for _, expr in ipairs(operations) do 
		if not self:ValidateRecord(expr, record) then
			return false
		end
	end
	return true
end

function _nor(self, record, operations) 
	for _, expr in ipairs(operations) do 
		if self:ValidateRecord(expr, record) then 
			return false
		end
	end
	return true
end

local selectorsMap = {
	_eq = _eq,
	_gt = _gt,
	_lt = _lt,
	_in = _in,
	_nin = _nin,
	_ne = _ne,
	_lte = _lte,
	_gte = _gte,
	_not = _not,
	_exists = _exists,
	_type = _type,
	_mod = _mod,
	_all = _all,
	_elemMatch = _elemMatch,
	_size = _size
}

local compoundSelectorsMap = {
	_or = _or,
	_and = _and,
	_nor = _nor
}

function DocumentStoreScript:IsCompoundOperator(key)
	return compoundSelectorsMap[key]
end

function DocumentStoreScript:ProcessSelector(record, field, selector, value)
	return selectorsMap[selector](self, record, field, value)
end

function DocumentStoreScript:ProcessSelectors(record, field, selectors)
	if self:IsCompoundOperator(field) then 
		return compoundSelectorsMap[field](self, record, selectors)
	else 
		for selector, value in pairs(selectors) do 
			if not self:ProcessSelector(record, field, selector, value) then 
				return nil
			end
		end
	end

	
	return true
end

function DocumentStoreScript:ValidateRecord(query, record)
	if not record then return end 
	
	for field, v in pairs(query) do 
		if type(v) == "table" and next(v) ~= nil then 
			if not self:ProcessSelectors(record, field, v) then
				return nil
			end
		else
			local memo = record
			for part in string.gmatch(field, "([^%.]+)") do 
				memo = memo[part]
				if memo == nil then 
					return nil
				end
			end

			if memo ~= v then 
				return nil
			end
			
		end
	end
	
	return record
end

function DocumentStoreScript:PersistData()
	if not IsServer() then 
		self:SendToServer("PersistData")
		return
	end
	
	self:GetEntity().documentStoresScript:PersistData()
end

function DocumentStoreScript:OnUserLogout(user)
	if user ~= self:GetEntity() then return end 
	
	self:PersistData()
end

return DocumentStoreScript
