local DropoffScript = {}

-- Script properties are defined here
DropoffScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "onDropoff", type = "event" },
	{ name = "dropoffTarget", type = "template" },
}

--This function is called on the server when this entity is created
function DropoffScript:Init()
end

function DropoffScript:OnTriggerEnter(player)
	local equips = player:FindAllScripts("equippableScript")
	for _, equip in ipairs(equips) do 
		if equip:GetEntity():GetTemplate() == self.properties.dropoffTarget then 
			self.properties.onDropoff:Send(player:GetUser())
		end
	end
end

return DropoffScript
