local DecoyScript = {}

-- Script properties are defined here
DecoyScript.Properties = {
	-- Example property
	{name = "grindEffect1", type = "effectasset"},
	{name = "grindEffect2", type = "effectasset"},
	{name = "grindEffect3", type = "effectasset"},
	
	{name = "grindSound1", type = "soundasset"},
	{name = "grindSound2", type = "soundasset"},
	{name = "grindSound3", type = "soundasset"},
	{name = "brokenGear", type = "template"},
	{name = "breakLocator", type = "entity"},
	{name = "explosion", type = "effectasset"},
	{name = "explosionSound", type = "soundasset"},
	{name = "user", type = "entity", editable = false }
}

--This function is called on the server when this entity is created
function DecoyScript:Init()
	self.grindSounds = {self.properties.grindSound1, self.properties.grindSound2, self.properties.grindSound3}
	self.gears = {}
end

function DecoyScript:SetUser(user)
	self.properties.user = user
end

function DecoyScript:GrindUp()
	self:Explosions()
end

function DecoyScript:Explosions()
self:Schedule(
		function()
			for i=1, 30 do
				Wait(.5)
				self:GetEntity():PlayEffect(self.properties.grindEffect1)
				self:GetEntity():PlayEffect(self.properties.grindEffect2)
				self:GetEntity():PlayEffect(self.properties.grindEffect3)
				local rand = math.random(1,2)
				if rand == 2 then self:Sounds() end
				
				local rand = math.random(1,2)
				if rand == 2 then self:BreakGear() end
			end
			for i=1,#self.gears do
				self.gears[i]:Destroy()
			end
			self:GetEntity():PlayEffect(self.properties.explosion,true)
			self:GetEntity():PlaySound(self.properties.explosionSound)
			Wait(.5)
			self:GetEntity():Destroy()
		end)
end

function DecoyScript:Sounds()			
				self:GetEntity():PlaySound(self.grindSounds[math.random(#self.grindSounds)])
end

function DecoyScript:BreakGear()			
	local gear = GetWorld():Spawn(self.properties.brokenGear,self.properties.breakLocator)
	table.insert(self.gears, gear)
end


return DecoyScript
