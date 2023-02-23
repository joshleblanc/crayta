local LocalSoundScript = {}

LocalSoundScript.Properties = {}

function LocalSoundScript:PlaySound(sound, fadeIn, group)
	if IsServer() then
		self:SendToLocal("PlaySound", sound, fadeIn, group)
		return
	end
	
	if fadeIn and group then
		return self:GetEntity():PlaySound(sound, fadeIn, group)
	elseif fadeIn then
		return self:GetEntity():PlaySound(sound, fadeIn)
	else
		return self:GetEntity():PlaySound(sound)
	end
	
end

function LocalSoundScript:PlaySound2D(sound, fadeIn, group)
	if IsServer() then
		self:SendToLocal("PlaySound2D", sound, fadeIn, group)
		return
	end
	if fadeIn and group then
		return self:GetEntity():PlaySound2D(sound, fadeIn, group)
	elseif fadeIn then
		return self:GetEntity():PlaySound2D(sound, fadeIn)
	else
		return self:GetEntity():PlaySound2D(sound)
	end
end

function LocalSoundScript:StopSound(sound, fadeOut)
	if IsServer() then
		self:SendToLocal("StopSound", sound, fadeOut)
		return
	end
	if fadeOut then
		self:GetEntity():StopSound(sound, fadeOut)
	else 
		self:GetEntity():StopSound(sound)
	end
end

return LocalSoundScript
