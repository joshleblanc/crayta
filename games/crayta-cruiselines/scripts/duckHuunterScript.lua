local DuckHunterScript = {}

-- Script properties are defined here
DuckHunterScript.Properties = {
	-- Example property
	{name = "duck", type = "template"},
	{name = "duckSound", type = "soundasset"},
	{name = "duckeffect", type = "effectasset"},
	{name = "amountOfDucks", type = "number"},
}

--This function is called on the server when this entity is created
function DuckHunterScript:Init()
	self.spawnedLocators = {}
	self.locations = self:GetEntity():GetChildren()
	self:HideDucks()
end

function DuckHunterScript:Reset()
	self.spawnedLocators = {}
	self.locations = self:GetEntity():GetChildren()
	self:HideDucks()
end

function DuckHunterScript:GetInteractPrompt(prompts)
	prompts.interact = "Pickup"
end

function DuckHunterScript:HideDucks()
	for i=1, self.properties.amountOfDucks do
		local rand = math.random(1,#self.locations)
		local duck = GetWorld():Spawn(self.properties.duck,Vector.Zero, Rotation.Zero)
		duck:AttachTo(self.locations[rand])
		duck:SetRelativePosition(Vector.Zero)
		duck:SetRelativeRotation(Rotation.Zero)
		table.insert(self.spawnedLocators, self.locations[rand])
		table.remove(self.locations,rand)
	end
end


function DuckHunterScript:DuckFound(player,hitResult,entity)
	local location = entity:GetParent():GetParent()
	local duck = entity:GetParent()
	local user = player:GetUser()
	
	user:SendXPEvent("collect-duck")
	user:AddToLeaderboardValue("ducks-found", 1)
	user:AddToLeaderboardValue("ducks-found-weekly", 1)
	
	-- 1 in 5 chance of finding a coin
	if math.random() < 0.20 then
		user:SendToScripts("AddMoney", 1, "You found a coin, too!")
	end
	
	location:PlaySound(self.properties.duckSound)
	location:PlayEffect(self.properties.duckeffect)
	
	duck:Destroy()
	
	for i=1,#self.spawnedLocators do
		if self.spawnedLocators[i] == location then
			self:SpawnNewDuck()
			table.insert(self.locations,self.spawnedLocators[i])
			table.remove(self.spawnedLocators,i)
			break
		else
		end
	end
end

function DuckHunterScript:SpawnNewDuck()
	local rand = math.random(1,#self.locations)
		local duck = GetWorld():Spawn(self.properties.duck,Vector.Zero, Rotation.Zero)
		duck:AttachTo(self.locations[rand])
		duck:SetRelativePosition(Vector.Zero)
		duck:SetRelativeRotation(Rotation.Zero)
		table.insert(self.spawnedLocators, self.locations[rand])
		table.remove(self.locations,rand)
end

return DuckHunterScript
