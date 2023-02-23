local DropRocketLauncher = {}

-- Script properties are defined here
DropRocketLauncher.Properties = {
}

function DropRocketLauncher:LocalInit() 
	
end

function DropRocketLauncher:OnButtonPressed(button)
	if button == "primary" then
		self:GetEntity():GetParent():GetUser().inventoryScript:SendToScript("RemoveTemplate", self:GetEntity():GetTemplate())
	end
end

return DropRocketLauncher
