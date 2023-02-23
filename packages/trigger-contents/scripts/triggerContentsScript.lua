local TriggerContentsScript = {}

-- Script properties are defined here
TriggerContentsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function TriggerContentsScript:Init()
	self.contents = {}
end

function TriggerContentsScript:OnTriggerEnter(entity)
	table.insert(self.contents, entity)
end

function TriggerContentsScript:ForEachEntity(fn)
	for _, entity in ipairs(self.contents) do 
		fn(entity)
	end
end

function TriggerContentsScript:OnTriggerExit(entity)
	local index = self:FindIndex(entity)
	if index > 0 then 
		table.remove(self.contents, index)
	end
end

function TriggerContentsScript:FindIndex(entity)
	for i, e in ipairs(self.contents) do 
		if e == entity then 
			return i
		end
	end
	
	return 0
end

return TriggerContentsScript
