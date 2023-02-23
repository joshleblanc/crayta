local FixNpcScript = {}

-- Script properties are defined here
FixNpcScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "npc", type = "entity", editable = true },
}

--This function is called on the server when this entity is created
function FixNpcScript:Fix()
	local pos = self:GetEntity():GetPosition()
	local rot = self:GetEntity():GetRotation()
	self:Schedule(function()
		while not self.properties.npc do 
			Wait()
		end
		Wait(1)
		print("Fixing npc...")	
		self.properties.npc:SetPosition(pos)
		--self.properties.npc:SetRotation(rot)
	end)
end

function FixNpcScript:ClientInit()
	self:Fix()
end

return FixNpcScript
