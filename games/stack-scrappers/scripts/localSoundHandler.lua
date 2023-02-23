local LocalSoundHandler = {}

-- Script properties are defined here
LocalSoundHandler.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function LocalSoundHandler:Init()
end

function LocalSoundHandler:PlaySoundLocally(sound)
	if IsServer() then 
		self:SendToLocal("PlaySoundLocally",sound)
	else
		self:GetEntity():PlaySound2D(sound)
	end
	
end


return LocalSoundHandler
