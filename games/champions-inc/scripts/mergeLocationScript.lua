local MergeLocationScript = {}

-- Script properties are defined here
MergeLocationScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "camera", type = "entity" }
}

--This function is called on the server when this entity is created
function MergeLocationScript:Init()
end

function MergeLocationScript:TrySetOwner(owner)
	print("Setting owner")
	self:Schedule(function()
		Wait()
		Wait()
		Wait()
		
		self.owner = owner
		
		self.owner:SetCamera(self.properties.camera)
		self.owner.userHeroMergeScript:ShowMergeWidget()
	end)
	
end

return MergeLocationScript
