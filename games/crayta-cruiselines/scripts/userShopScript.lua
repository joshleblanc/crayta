local UserShopScript = {}

-- Script properties are defined here
UserShopScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserShopScript:Init()
end

function UserShopScript:LocalInit()
	self.entity = self:GetEntity()
	self.widget = self.entity.userShopWidget
	self.data = self.entity.saveDataScript
	self.items = self.entity:FindAllScripts("userShopItemScript")
	self:UpdateWidget()
end

function UserShopScript:Buy(id, name)
	self.entity:SendToScripts("LocalConfirm", FormatString("Are you sure you want to buy <span class='message--highlight'>{1}</span>?", name), function(response)
		if response then
			self.entity:SendToScripts("SaveData", FormatString("shop-owned-{1}", id), true)
			self:UpdateWidget()
		end
	end)

end

function UserShopScript:UpdateWidget()
	local items = {}
	for _, v in ipairs(self.items) do
		local owned = self.data:GetData(FormatString("shop-owned-{1}", v.properties.id))
		print(v.properties.icon:GetIcon())
		table.insert(items, {
			name = v.properties.name,
			id = v.properties.id,
			icon = v.properties.icon:GetIcon(),
			price = v.properties.price,
			owned = owned
		})
	end
	self.widget.js.data.items = items
end

return UserShopScript
