local ZoomSoundControllerScript = {}

ZoomSoundControllerScript.Properties = {
	{ name = "zoomSound", type = "soundasset" },
	{ name = "hitSound", type = "soundasset" }
}

function ZoomSoundControllerScript:ClientInit()
	self.playingZoom = false
	self.playingHit = false
end

-- This is run on the client, in floaty#CheckPlayers
function ZoomSoundControllerScript:PlayZoomSound(what)
	self:Schedule(function()
		if self.playingZoom then return end 

		self.playingZoom = true
		
		what:PlaySound(self.properties.zoomSound)
		
		Wait(0.5)
		self.playingZoom = false
	end)
end

function ZoomSoundControllerScript:PlayHitSound(what)
	self:Schedule(function()
		if self.playingHit then return end 

		self.playingHit = true
		what:PlaySound(self.properties.hitSound)
		
		Wait(1)
		self.playingHit = false
	end)
end

return ZoomSoundControllerScript
