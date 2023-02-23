local CartHealScript = {}

-- Script properties are defined here
CartHealScript.Properties = {
	-- Example property
	{name = "aliveTemplate", type = "template"},
	{name = "healSpell", type = "effectasset"},
	{name = "healSound", type = "soundasset"},
	{name = "healAmount", type = "number", default = 100},
	{name = "healWaitTime", type = "number", default = 10},
}

--This function is called on the server when this entity is created
function CartHealScript:Init()
	self:Start()
end

function CartHealScript:Start()
	self:Schedule(function()
		
		self:FindPlayersInTrigger()
		local pos = self:GetEntity():GetPosition() + Vector.New(0,0,-200)
		self:GetEntity():PlayEffectAtLocation(pos,Rotation.Zero,self.properties.healSpell)
		self:GetEntity():PlaySound(self.properties.healSound)
		Wait(self.properties.healWaitTime)
		self:Start()
		
	end)
end

function CartHealScript:Heal(player)
	player:SendToScripts("Heal",self.properties.healAmount, self:GetEntity():GetParent())
end

function CartHealScript:FindPlayersInTrigger()
	GetWorld():ForEachUser(function(userEntity)
		if userEntity:GetPlayer() and userEntity:GetPlayer():IsAlive() then
			local player = userEntity:GetPlayer()
			local temp = player:GetTemplate()
			if temp == self.properties.aliveTemplate and self:GetEntity():IsOverlapping(player) then
				self:Heal(player)
			end
		end
	end)
return players
end

return CartHealScript

