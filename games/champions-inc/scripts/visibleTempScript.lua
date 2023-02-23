local VisibleTempScript = {}

-- Script properties are defined here
VisibleTempScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function VisibleTempScript:Init()
	self:SetVisible()
end

function VisibleTempScript:SetVisible()
	self:Schedule(function()
		Wait(30)
		local children = self:GetEntity():GetChildren()
		for i=1, #children do
			if children[i]:IsA(Character) then
				children[i].visible = true
				print("setting NPC visible fix")
			end
		end
	
	end)

end

return VisibleTempScript
