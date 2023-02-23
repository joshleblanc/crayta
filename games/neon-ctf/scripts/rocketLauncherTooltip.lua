local RocketLauncherTooltip = {}

-- Script properties are defined here
RocketLauncherTooltip.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "template", type = "template" }
}

function RocketLauncherTooltip:OnTick()

	-- this code fucking sucks
	-- If the parent's parent's parent is a character, it means we were picked up, 
	-- and should show the tooltip
	-- If our parent's parent is a character, we're already picked up. If we're holding the rocketlauncher, 
	-- display the tooltip
	-- Otherwise don't
	-- Note: We straight up destroy the locator. I'm 98% sure when you switch weapons, the entity is destroyed,
	-- so when it's held again the locator will appear again.
	if self:GetEntity():GetParent():IsA(Character) then 
		if self:GetEntity():GetParent():FindScriptProperty("heldTemplate") == self.properties.template then
			self:GetEntity().visible = true
		else
			self:GetEntity():Destroy()
		end
	elseif self:GetEntity():GetParent():GetParent() and self:GetEntity():GetParent():GetParent():IsA(Character) then
		self:GetEntity().visible  = true
		self:GetEntity():AttachTo(self:GetEntity():GetParent():GetParent())
	else
		self:GetEntity():Destroy()
	end
end

return RocketLauncherTooltip
