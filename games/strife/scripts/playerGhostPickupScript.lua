local PlayerGhostPickupScript = {}

-- Script properties are defined here
PlayerGhostPickupScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerGhostPickupScript:Init()
end

function PlayerGhostPickupScript:SetGhostPickup(script)
	self.script = script
end

function PlayerGhostPickupScript:UnsetGhostPickup(script)
	if script == self.script then 
		self.script = nil
	end
end

function PlayerGhostPickupScript:LocalOnButtonReleased(btn)
	if btn == "interact" then
	 
		if self.holdingSchedule then 
			self:Cancel(self.holdingSchedule)
		end
		
		self.opening = false
		
		if self.script then 
			self.script:StopOpening()
		end
	end
end

function PlayerGhostPickupScript:LocalOnButtonPressed(btn)
	
	if btn == "interact" then 
		if not self.script then return end 
		
		if self.holdingSchedule then 
			self:Cancel(self.holdingSchedule)
		end
		
		self.opening = true
		self.script:StartOpening()
		
		self.holdingSchedule = self:Schedule(function()
			Wait(1)
			if self.opening then 
				self:Open()
			end
			self.opening = false
		end)
	end
end

function PlayerGhostPickupScript:Open()
	self.script:Open()
	
	self:SendToServer("ServerOpen", self.script)
end

function PlayerGhostPickupScript:ServerOpen(script)
	local buff = script.properties.buffId
	local curse = script.properties.curseId
	
	local user = self:GetEntity():GetUser()
	
	user:SendToScripts("ApplyBuff", script.properties.buffId, script.properties.buffDescription)
	user:SendToScripts("ApplyCurse", script.properties.curseId, script.properties.curseDescription)
	user:SendToScripts("UpdateModifiersWidget")
end

return PlayerGhostPickupScript
