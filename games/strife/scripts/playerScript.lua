local PlayerScript = {}

-- Script properties are defined here
PlayerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "isGhost", type = "boolean", default = false },
	{ name = "invulnerable", type = "boolean", default = false }
}

function PlayerScript:Init()
	self.properties.invulnerable = true
	self:Schedule(function()
		Wait(3)
		self.properties.invulnerable = false
	end)
	
	self:GetEntity():GetUser().inventoryScript:Reset()
end

-- When you spawn, hide everyone not in your realm
function PlayerScript:LocalInit()
	local pickups = GetWorld():FindAllScripts("ghostPickupScript")
	for _, pickup in ipairs(pickups) do 
		if self.properties.isGhost then 
			pickup:GetEntity():SendToScripts("SetVisibilityOn")
		else 
			pickup:GetEntity():SendToScripts("SetVisibilityOff")
		end 
	end

	GetWorld():ForEachUser(function(user)
		local player = user:GetPlayer()
		
		if self.properties.isGhost then 
			player:SendToScripts("SetVisibilityOn")
		else
			if player:FindScriptProperty("isGhost") then 
				player:SendToScripts("SetVisibilityOff")
			else
				player:SendToScripts("SetVisibilityOn")
			end
		end 
		
		if player:FindScriptProperty("isGhost") then 
			player.visible = false
			player:SendToScripts("ShowTrail")
		end
	end)
end

-- whenever a new player spanws, only show people in the local realm
function PlayerScript:ClientInit()
	local user = GetWorld():GetLocalUser()
	local player = user:GetPlayer()
	
	-- show everyone if you're a ghost
	if player:FindScriptProperty("isGhost") then 
		self:GetEntity():SendToScripts("SetVisiblityOn")
	else
		-- if you're not a ghost, and they are, hide them
		if self.properties.isGhost then 
			self:GetEntity():SendToScripts("SetVisibilityOff")
		end
	end
	
	if self.properties.isGhost then 
		self:GetEntity().visible = false
		self:GetEntity():SendToScripts("ShowTrail")
	end
end

return PlayerScript
