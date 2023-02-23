local PlayerMovementScript = {}

-- Script properties are defined here
PlayerMovementScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "magnet", type = "entity" },
}

--This function is called on the server when this entity is created
function PlayerMovementScript:Init()
	self.initialSpeed = self:GetEntity().speedMultiplier
end

function PlayerMovementScript:OnTick()
	if self.properties.magnet:FindScriptProperty("pulling") then
		self:GetEntity().speedMultiplier = self.initialSpeed
	else
		local slowRange = self.properties.magnet:FindScriptProperty("magnetSlowRange")
		local magnetPos = self.properties.magnet:FindScriptProperty("pullStartLocator"):GetPosition()
		local distance = Vector.Distance(magnetPos, self:GetEntity():GetPosition())
		if distance > slowRange then
			self:GetEntity().speedMultiplier = self.initialSpeed
		else
			local percent = distance / slowRange
			self:GetEntity().speedMultiplier = self.initialSpeed * percent
		end
	end
	
	
	if self:GetEntity():FindScriptProperty("inOilSlick") then
		self:GetEntity().speedMultiplier = math.min(self:GetEntity().speedMultiplier, self:GetEntity():FindScriptProperty("oilSlickSpeedMultiplier"))
	end
end

return PlayerMovementScript
