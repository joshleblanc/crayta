local BlockScript = {}

-- Script properties are defined here
BlockScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "num", type = "number", default = 0 },
	{ name = "x", type = "number" },
	{ name = "y", type = "number" },
	{ name = "active", type = "boolean", default = false },
	{ name = "moveSound", type = "soundasset" },
	{ name = "combineSound", type = "soundasset" }
}

--This function is called on the server when this entity is created
function BlockScript:Init()
end

--[[
	There used to be a StopMoveSound method that stopped the sound after the
	move was completed by gridScript, but it didn't always stop the sound.
	Rather than fight with that, just stop it manually in the same function
]]--
function BlockScript:PlayMoveSound()
	local moveSoundHandle = self:GetEntity():PlaySound(self.properties.moveSound)
	self.moveSoundHandle = moveSoundHandle
	self:Schedule(function()
		Wait(0.1)
		self:GetEntity():StopSound(moveSoundHandle, 0.5)
	end)
end

function BlockScript:ClientInit()
	self.widget = self:GetEntity():FindWidget("numberWidget", true)
	self.moveSoundHandles = {}
end

function BlockScript:IsA(x, y, num)
	local matchPos = self.properties.x == x and self.properties.y == y
	if num then
		return matchPos and self.properties.num == num
	else
		return matchPos
	end
end

function BlockScript:SetPos(x, y)
	self.properties.x = x 
	self.properties.y = y 
end

function BlockScript:IsAvailable()
	return not self.properties.active
end

function BlockScript:Flash()
	self.widget:CallFunction("Flash")
end

function BlockScript:IsActive()
	return self.properties.active
end

function BlockScript:IsOverlapping(other)
	return other.blockScript:IsA(self.properties.x, self.properties.y) and other.blockScript:IsActive()
end

function BlockScript:SetNumber(num)
	self.widget.js.data.num = num
end

function BlockScript:Show()
	self.widget:Show()
	self.widget.js.data.opacity = 1
	self:GetEntity().visible = true
	self.properties.active = true
end

function BlockScript:HideNumber(duration)
	self:Schedule(function()
		local opacity = 1
		local timeTaken = 0
		while timeTaken <= duration do
			local dt = Wait()
			timeTaken = timeTaken + dt
			local p = timeTaken / duration 
			self.widget.js.data.opacity = math.lerp(1, 0, p)
		end
		self.widget:Hide()
	end)
end

function BlockScript:Hide()
	self.widget.js.data.opacity = 1
	self.widget:Hide()
	self:GetEntity().visible = false
	self.properties.active = false
end

return BlockScript
