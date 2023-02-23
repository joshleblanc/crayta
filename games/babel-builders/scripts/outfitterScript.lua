local OutfitterScript = {}

OutfitterScript.Properties = {
	{ name = "equipment", type = "template" },
	{ name = "workingSounds", type = "soundasset", container = "array" },
	{ name = "workingEffects", type = "effectasset", container = "array" },
	{ name = "role", type = "string" },
	{ name = "trigger", type = "entity" }
}

function OutfitterScript:Init()
	self.properties.trigger.onInteract:Listen(self, "HandleEnter")
end

function OutfitterScript:HandleReachedCheckpoint(user, index)
	if index == 2 then
		self:HandleInside(user)
	elseif index == 3 then
		self:HandleExit()
	end
end

function OutfitterScript:HandleExit()
	self.busy = false
end

function OutfitterScript:HandleInside(user)
	local player = user:GetPlayer()
	
	for i=1,#self.properties.workingSounds do
		self:GetEntity():PlaySound(self.properties.workingSounds[i])
	end
	
	if #self.properties.workingEffects > 0 then
		for i=1, #self.properties.workingEffects do
			self:GetEntity():PlayEffect(self.properties.workingEffects[i],true)
		end
	end
	
	local axe = GetWorld():Spawn(self.properties.equipment, Vector.Zero, Rotation.Zero)
	axe:AttachTo(player, "weapon_r")
	player:SetGrip(axe:FindScriptProperty("grip"))
	player:SendToScripts("SetRole", self.properties.role, axe)
	Wait(3)
end

function OutfitterScript:HandleEnter(player) 
	local user = player:GetUser()
	
	if self.busy then
		user:SendToScripts("Shout", "This station is in use, come back in a few moments")
		return
	end
	
	if player:FindScriptProperty("holding") then
		user:SendToScripts("Shout", "Come back when you're not carrying something!")
		return
	end
	
	self.busy = true
	self:GetEntity().pathScript:Follow(user)	
end

return OutfitterScript
