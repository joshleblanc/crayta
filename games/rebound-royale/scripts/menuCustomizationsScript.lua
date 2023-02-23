local MenuCustomizationsScript = {}

-- Script properties are defined here
MenuCustomizationsScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "defaultCustomization", type = "template" }
}

--This function is called on the server when this entity is created
function MenuCustomizationsScript:Init()
	self.db = self:GetEntity().documentStoresScript:GetDb("default")
	local doc = self.db:FindOne()
	if not doc then 
		self.db:InsertOne({
			equippedCustomization = self.properties.defaultCustomization:GetName()
		})
	end
end

function MenuCustomizationsScript:LocalInit()
	self.db = self:GetEntity().documentStoresScript:GetDb("default")
	self.widget = self:GetEntity().menuCustomizationsWidget
	
	self.widget:Hide()
end

function MenuCustomizationsScript:ShowHomeMenu()
	self.widget:Hide()
end

function MenuCustomizationsScript:ShowCustomizationsMenu()
	self.widget:Show()
	
	self:GetEntity():GetLeaderboardValue("most-wins", function(score, rank)
		local customizations = self:GetEntity():FindAllScripts("customizationScript")
		local data = {}
		
		for _, customization in ipairs(customizations) do 
			table.insert(data, {
				equipped = self.db:FindOne().equippedCustomization == customization.properties.template:GetName(),
				requirement = customization.properties.requirement,
				enabled = score >= customization.properties.requirement,
				templateName = customization.properties.template:GetName(),
				image = customization.properties.image
			})	
		end	
		
		table.sort(data, function(a,b) 
			return a.requirement < b.requirement
		end)
		
		self.widget.js.data.customizations = data
	end)

end

function MenuCustomizationsScript:SelectCustomization(templateName)
	self.db:UpdateOne({}, {
		_set = {
			equippedCustomization = templateName
		}
	})
	self:UpdateCustomizations()
end

return MenuCustomizationsScript
