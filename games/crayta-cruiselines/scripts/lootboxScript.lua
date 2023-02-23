local LootboxScript = {}

-- Script properties are defined here
LootboxScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "smokeRing", type = "effectasset" },
	{ name = "camera", type = "entity" },
	{ name = "landingSound", type = "soundasset" },
	{ name = "openingSound", type = "soundasset" },
	{ name = "shimmerSound", type = "entity" },
	{ name = "revealSound", type = "soundasset" },
	{ name = "lightBeam", type = "entity" },
	{ name = "lightGlow", type = "entity" }
}

--This function is called on the server when this entity is created
function LootboxScript:Init()
end

function LootboxScript:ClientInit()
	self:Schedule(function()
		Wait()
		--self:Play(GetWorld():GetLocalUser())
	end)
end

function LootboxScript:FindItem()
	local items = self:GetEntity():FindAllScripts("lootboxItemScript")
	local index = math.random(1, #items)
	print("num items", #items, index)
	return items[index]
end

function LootboxScript:Play(user)
	if IsServer() then
		user:SetCamera(self.properties.camera)
		self:SendToAllClients("Play", user)
		return
	end
	
	if GetWorld():GetLocalUser() ~= user then return end 
	
	user.userLootBoxScript:Show(self)
	
	self:Schedule(function()
		local originalPosition = self:GetEntity():GetPosition()
		
		self:GetEntity():SetPosition(self:GetEntity():GetPosition() - Vector.New(0, 0, -200))
		
		Wait()
		
		Wait(self:GetEntity():PlayTimeline(
			0, self:GetEntity():GetPosition(), "EaseOut",
			0.1, originalPosition - Vector.New(0,0,5)
		))
		self:GetEntity():PlaySound(self.properties.landingSound)
		self:GetEntity():PlayEffect(self.properties.smokeRing)
		
		Wait(self:GetEntity():PlayTimeline(
			0, originalPosition - Vector.New(0,0,5),
			0.2, originalPosition, "EaseOut"
		))
		
	end)
end

function LootboxScript:Open()
	local playbackTime = 3
	self.properties.lightBeam.active = true
	self.properties.lightGlow.active = true
	self.properties.shimmerSound.active = true
	self:GetEntity():PlaySound(self.properties.openingSound)
	self:GetEntity():PlayAnimation("Opening", {
		playbackTime = playbackTime
	})
	return playbackTime
end

function LootboxScript:PlayRevealSound()
	self:GetEntity():PlaySound(self.properties.revealSound)
end

function LootboxScript:Close()
	
	self.properties.lightBeam.active = false
	self.properties.lightGlow.active = false
	self.properties.shimmerSound.active = false
	self:GetEntity():PlayAnimation("Closing")
end

function LootboxScript:ResetCamera(user)
	user:SetCamera(user:GetPlayer())
end

return LootboxScript
