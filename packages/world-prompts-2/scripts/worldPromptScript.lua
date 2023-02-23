local PlayerWorldPromptScript = {}

-- Script properties are defined here
PlayerWorldPromptScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function PlayerWorldPromptScript:LocalInit()
	self.lookingAt = nil
end

function PlayerWorldPromptScript:LocalOnTick()
	local hitEntity, hitResult = self:GetEntity():GetInteraction()
	
	-- if we're looking at someting new 
	if hitEntity ~= self.lookingAt then 

		-- If we were looking at something before, hide it 
		if self.lookingAt then 
			self.lookingAt:SendToScripts("Hide")
			self.lookingAt = nil
		end
	
		-- if it's a prompt, show it
		if hitEntity and hitEntity.worldPromptScript then 

			hitEntity:SendToScripts("Show")
			
			self.lookingAt = hitEntity
		end
	end
	
end

return PlayerWorldPromptScript
