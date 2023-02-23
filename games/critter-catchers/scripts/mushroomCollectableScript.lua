local MushroomCollectableScript = {}

-- Script properties are defined here
MushroomCollectableScript.Properties = {
	-- Example property
	{name = "feedValue", type = "number", default = 20},
	{name = "eatenEffect", type = "effectasset"},
	{name = "glowEffect", type = "entity"},
	{name = "colorLight", type = "entity"},
	{name = "spawnEffect", type = "effectasset"},
	{name = "spawnSound", type = "soundasset"},
	{name = "colorshape", type = "entity"},
	{name = "allShapes", type = "entity",},
}

--This function is called on the server when this entity is created
function MushroomCollectableScript:Init()
	self.collectable = false
	self.colorList = {
	--Color.New(148,0,211),
	--Color.New(75,0,130),
	Color.New(0,0,255),
	Color.New(0,255,0),
	Color.New(255,0,0),
	--Color.New(255,255,0),
	--Color.New(255,127,0),
	
	}
end

function MushroomCollectableScript:HandleEnterTrigger(player)
	if self.collectable and player:IsA(Character) then
		self.collectable = false
		player:GetUser():SendToScripts("FeedCompanion", self.properties.feedValue, self.properties.colorLight.color)
		
		self:GetEntity():PlayEffect(self.properties.eatenEffect)
		self.properties.glowEffect.active = false
		self.properties.colorLight.visible = false
		
		local shapes = {}
		shapes = self.properties.allShapes:GetChildren()
		for i=1, #shapes do
			shapes[i].visible = false
		end
	end
end

function MushroomCollectableScript:ActivateMushroom()
	if self.collectable == false then
		local rand = math.random(1,#self.colorList)
		color = self.colorList[rand]
		self.properties.colorLight.color = color
		self.properties.colorshape.color = color
		self.properties.glowEffect.assetProperties.color = color
		self.properties.glowEffect.active = true
		self.properties.colorLight.visible = true
		local shapes = {}
		shapes = self.properties.allShapes:GetChildren()
		for i=1, #shapes do
			shapes[i].visible = true
		end
		self.collectable = true
		
		self.properties.glowEffect.active = true
		self:GetEntity():PlayEffect(self.properties.spawnEffect)
		self:GetEntity():PlaySound(self.properties.spawnSound)
	end
end

return MushroomCollectableScript
