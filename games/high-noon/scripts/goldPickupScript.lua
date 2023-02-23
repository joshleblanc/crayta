local GoldPickupScript = {}

-- Script properties are defined here
GoldPickupScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "gold", type = "number", default = 0, editable = false },
	{ name = "template", type = "template" },
	{ name = "starTemplate", type = "template" },
	{ name = "goldPickupSound", type = "soundasset" },
	{ name = "star", type = "entity", editable = false },
	{ name = "mvp", type = "entity", editable = false },
	{ name = "dropSpread", type = "number", default = 600 }
}

function GoldPickupScript:Init()
	local player = self:GetEntity()
	self.properties.star = GetWorld():Spawn(self.properties.starTemplate, Vector.Zero, Rotation.Zero)
	self.properties.star:AttachTo(player)
	self.properties.star.visible = false
	
	local pos = player:GetPosition()	
	self.properties.star:SetPosition(pos + Vector.New(0, 0, 100))
end

function GoldPickupScript:LocalInit()
	self.widget = self:GetEntity().goldWidget
end

-- Pass the amount in because there was some timing issues
-- when using self.properties.gold direct
function GoldPickupScript:UpdateWidget(amount)
	if IsServer() then
		self:SendToLocal("UpdateWidget", amount)
		return
	end
	
	self.widget.js.gold.amount = amount
end

function GoldPickupScript:MostValuablePlayer()
	local mvp = nil
	local maxGold = 0
	GetWorld():ForEachUser(function(user) 
		local player = user:GetPlayer()
		if player then
			local script = player:GetUser().scoreScript
			if script.properties.score > maxGold then
				mvp = user
				maxGold = script.properties.score
			end
		end
	end)
	
	return mvp
end

function GoldPickupScript:NotifyUsers()
	local name = "Nobody"
	local mvp = self.properties.mvp
	
	if mvp then
		name = mvp:GetUsername()
	end

	GetWorld():ForEachUser(function(user)
		user:SendToScripts("AddNotification", "{1} has the most gold!", name)
		local player = user:GetPlayer()
		if player then
			player.goldPickupScript.properties.star.visible = false
		end
	end)
	
	if mvp then
		print("Showing")
		mvp:GetPlayer().goldPickupScript.properties.star.visible = true
		mvp:GetPlayer().goldPickupScript:SendToLocal("HideStar")
	end

end

function GoldPickupScript:HideStar()
	print("Hiding")
	local player = self:GetEntity()
	
	if player then
		self.properties.star.visible = false
	end
end

--This function is called on the server when this entity is created
function GoldPickupScript:Pickup(player, fromEntity)

	if player ~= self:GetEntity() then
		return
	end
	player:PlaySound(self.properties.goldPickupSound)
	local mvpBefore = self:MostValuablePlayer()
	
	local user = player:GetUser()

	user.scoreScript:SendToScript("AddScore", 1)
	
	local mvpAfter = self:MostValuablePlayer()
	
	if mvpBefore ~= mvpAfter then
		self.properties.mvp = mvpAfter
		self:NotifyUsers()
	end
	self:UpdateWidget(user.scoreScript.properties.score)
	
	local pickupSpawnerScript = fromEntity:FindScript("pickupSpawnerScript", true)
	if pickupSpawnerScript.properties.singlePickup then
		pickupSpawnerScript:Remove()
	end
end

function GoldPickupScript:Drop(userEntity, fromEntity, selfMsg, otherMsg, youKilledMsg)
	if userEntity ~= self:GetEntity() then
		return
	end
	print("Dropping gold")
	local mvpBefore = self:MostValuablePlayer()
	
	local centerPosition = self:GetEntity():GetPosition()
	local user = self:GetEntity():GetUser()
	
	local spreadHigh = self.properties.dropSpread
	local spreadHalf = spreadHigh / 2
	local score = user.scoreScript.properties.score
	self:Schedule(function()			
		print("Dropping {1} gold", score)
		for i=1,score do
			local newPosition = centerPosition
			local entity = GetWorld():Spawn(self.properties.template, newPosition, Rotation.Zero)
			
			local script = entity:FindScript("pickupSpawnerScript", true)
			script:ShowPickup()
			script.properties.singlePickup = true
			
			entity:SendToScripts("Fly")
			Wait()
		end
	end)
	
	
	user.scoreScript:ResetScore()
	
	local mvpAfter = self:MostValuablePlayer()
	
	if mvpAfter ~= mvpBefore then
		self.properties.mvp = mvpAfter
		self:NotifyUsers()
	end
	
	self:UpdateWidget(user.scoreScript.properties.score)
end

return GoldPickupScript
