local EquippableScript = {}

-- Script properties are defined here
EquippableScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "socket", type = "string" },
	{ name = "rotation", type = "rotation" },
}

--This function is called on the server when this entity is created
function EquippableScript:Init()
end

function EquippableScript:Equip(user, item)
	print("Equipping", item:GetName())
	local alreadyEquipped = self:FindAlreadyEquipped(user)
	
	if alreadyEquipped then
		local alreadyEquippedTemplate = alreadyEquipped:GetEntity():GetTemplate()
		print("Already have item equipped in ", self.properties.socket)
		user:GetPlayer():SetNoGrip()

		alreadyEquipped:GetEntity():Destroy()
		print("Destroying already equipped item")
		if alreadyEquippedTemplate == self:GetEntity():GetTemplate() then 
			self:GetEntity():Destroy()
		else
			print("Equipping new item")
			self:_Equip(user, item)
		end
	else
		self:_Equip(user, item)
	end
end

function EquippableScript:_Equip(user, item)
	item:AttachTo(user:GetPlayer(), self.properties.socket)
	item:SetRelativeRotation(self.properties.rotation)
	item.collisionEnabled = false
	user:GetPlayer():SetGrip(item:FindScriptProperty("grip"))
end

function EquippableScript:FindAlreadyEquipped(user)
	local equipped = user:GetPlayer():FindAllScripts("equippableScript")
	
	for _, equip in ipairs(equipped) do 
		if equip.properties.socket == self.properties.socket then 
			return equip
		end
	end
	
	return nil
end

return EquippableScript
