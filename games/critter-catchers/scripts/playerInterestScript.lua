local PlayerInterestTriggerScript = {}

-- Script properties are defined here
PlayerInterestTriggerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerInterestTriggerScript:Init()
	self.listOfInterests = {}
	self:Clean()
end

function PlayerInterestTriggerScript:OnTriggerEnter(entity)
	if entity ~= nil and entity:IsValid() and entity:IsA(NPC) then
		table.insert(self.listOfInterests, entity)
		print(#self.listOfInterests, "interests")
	end
end

function PlayerInterestTriggerScript:OnTriggerExit(entity)
	if entity ~= nil and entity:IsValid() and entity:IsA(NPC) then
		for i=1, #self.listOfInterests do
			if self.listOfInterests[i] == entity then
				table.remove(self.listOfInterests,i)
				print(#self.listOfInterests, "interests")
			end
		end
	end
end

function PlayerInterestTriggerScript:Clean()
	self:Schedule(function()
		while true do
		Wait(2)
			for i=1, #self.listOfInterests do
				if not self:GetEntity():IsOverlapping(self.listOfInterests[i]) then
					table.remove(self.listOfInterests,i)
					print("Removed junk")
				end
			end
		end
	end)
end

return PlayerInterestTriggerScript
