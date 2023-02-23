local HitEffectScript = {}

-- Script properties are defined here
HitEffectScript.Properties = {
	-- Example property
	{name = "effectSound", type = "soundasset"},
	{name = "effectVisual", type = "effectasset"},
	{name = "effectTimer", type = "number", default = 2},
	{name = "animated", type = "boolean", default = false},
	{name = "hasAnimationParentLocator", type = "boolean", default = false},
	{name = "visibleSwitch", type = "boolean", default = false},
	{name = "timeInvisible", type = "number", default = 0},
	{name = "turnEffectOffTime", type = "number", default = 2},
	
}

--This function is called on the server when this entity is created
function HitEffectScript:Init()
	self.playingEffects = false
end

function HitEffectScript:EntityHit(hit,user)
	if self.playingEffects == false then
		self:Schedule(
			function()
				self.playingEffects = true
				if self.properties.animated then
					if self.properties.hasAnimationParentLocator then
						self:GetEntity():GetParent().mightyAnimationScript:Play()
					else
						self:GetEntity().mightyAnimationScript:Play()
					end
				end
				
				
				
				if self.properties.visibleSwitch then
					self:GetEntity().visible = false
				end
				
				self.playingEffects = true
				if self.properties.effectVisual then
				self.effect = self:GetEntity():PlayEffectAtLocation(hit:GetPosition(),Rotation.FromVector(hit:GetNormal()),self.properties.effectVisual)
				end
				if self.properties.effectSound then
				self.sound = self:GetEntity():PlaySoundAtLocation(self:GetEntity():GetPosition(),self.properties.effectSound)
				end
				
				Wait(self.properties.turnEffectOffTime)
				self:GetEntity():StopEffect(self.effect)
				
				Wait(self.properties.effectTimer)
				self:GetEntity():StopSound(self.sound)
				
				Wait(self.properties.timeInvisible)
				self:GetEntity().visible = true
				self.playingEffects = false
			end)
	end
end

function HitEffectScript:Reset()
	
end

return HitEffectScript
