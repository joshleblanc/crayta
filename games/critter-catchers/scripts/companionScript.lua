
local CompanionScript = {}

-- Script properties are defined here
CompanionScript.Properties = {
	-- Example property
	{name = "myCompanionTemplate", type = "template"},
	{name = "spawnEffect", type = "effectasset"},
	{name = "spawnSound", type = "soundasset"},
	{name = "playerTemplate", type = "template"},
	{name = "spawnLocator", type = "entity"},
	{name = "companionHappiness", type = "number", default = 100},
	{name = "pickupSound", type = "soundasset"},
	{name = "companionHappySound", type = "soundasset"},
	{name = "companionEatSound", type = "soundasset"},
	{name = "companionEatEffect", type = "effectasset"},
	{name = "speakingSounds", type = "soundasset", container = "array"},
	{name = "companionGreetingSound", type = "soundasset", container = "array"},
	
	{name = "myCompanion", type = "entity", editable = false },
	{name = "pointOfInterest", type = "entity", editable = false },
	{name = "debug", type = "boolean", default = false }
}

--This function is called on the server when this entity is created
function CompanionScript:Init()

end

function CompanionScript:StartLocal()
	self:SendToServer("Start")
	self:InitWidget()
end

function CompanionScript:Start()
	self.companionData = self:GetSaveData()
	self:GetEntity():SpawnPlayer(self.properties.playerTemplate, self.properties.spawnLocator)
	
	self.idleTime = 0
	self.playerInterestTriggerScript = self:GetEntity():GetPlayer():FindScript("playerInterestTriggerScript",true)
	
	self:Schedule(function()
		Wait()	
		self.properties.myCompanion = GetWorld():Spawn(self.properties.myCompanionTemplate, self:GetEntity():GetPlayer():GetPosition() + Vector.New(-250,0,0), Rotation.Zero)
		self.properties.myCompanion:PlayEffect(self.properties.spawnEffect)
		local spawnSound = self.properties.myCompanion:PlaySound(self.properties.spawnSound)
		spawnSound:SetPitch(2)
		spawnSound:SetVolume(1)
		Wait()

		self.companionCam = self.properties.myCompanion:FindScriptProperty("cam")
		self.lightEffect = self.properties.myCompanion:FindScriptProperty("lightEffect")
		self.colorPieces = self.properties.myCompanion:FindScriptProperty("colorPieces")
		self.colorEffect = self.properties.myCompanion:FindScriptProperty("colorEffect")
		print(self.properties.myCompanion, "The companion")
		Wait(2)
		self:SendToAllClients("StartClient")
		Wait(2)
		self:SendToAllClients("SetMyCompanion", self.properties.myCompanion)
		
		if self.companionData.color then
			local red = self.companionData.red
			local green = self.companionData.green
			local blue = self.companionData.blue
			local color = Color.New(red, green, blue)
			self:SetColorInfluence(color)
		end
	end)
end

function CompanionScript:StartClient()
	self:Schedule(function()
		Wait(2)

		self.idleTime = 0
	end)
end

function CompanionScript:InitWidget()
	self.companionWidget = self:GetEntity():FindWidget("companionHappinessWidget")
	self.companionWidget.visible = true
end

function CompanionScript:ServerUpdateCompanion(pos, rot)
	self.properties.myCompanion:SetPosition(pos)
	self.properties.myCompanion:SetRotation(rot)
end

function CompanionScript:UpdateClients(companion)
	self.properties.myCompanion = companion
end

function CompanionScript:OnUserLogout(user)
	if user == self:GetEntity() then
		self.properties.myCompanion:Destroy()
	end
end

function CompanionScript:Speak(text)
	self:Schedule(function()
		local _, spaceCount = string.gsub(text, " ", "")
		self:SetCompanionCam((spaceCount+1)/2)
		self:GetEntity():SendToScripts("Shout",text, (spaceCount+1)/2)
		local wordTime = (((spaceCount+1)/2)/spaceCount)/2
		for i=1, spaceCount + 1 do
			local rand = math.random(1,#self.properties.speakingSounds)
			local pitchRand = math.random(1.0,2.0)
			local sound = self:GetEntity():GetPlayer():PlaySound(self.properties.speakingSounds[rand],1,"speech")
			sound:SetPitch(pitchRand)
			sound:SetVolume(.8)
			Wait(wordTime)
		end
	end)
end

function CompanionScript:OnButtonPressed(btn)
	if not self.properties.debug then return end 
	
	if btn == "secondary" then 
		self:SetCompanionCam(1)
	end
	
end

function CompanionScript:SetCompanionCam(time)
	self:Schedule(function()
		self:GetEntity():GetPlayer():SetInputLocked(true)
		Wait(self:GetEntity():SetCamera(self.companionCam,.5))
		Wait(time)
		self:GetEntity():SetCamera(self:GetEntity():GetPlayer(),.8)
		self:GetEntity():GetPlayer():SetInputLocked(false)
	end)
end



function CompanionScript:SetMyCompanion(companion)
		self.properties.myCompanion = companion
		self.lightEffect = lightEffect
		self.companionCam = self.properties.myCompanion:FindScriptProperty("cam")
		self.lightEffect = self.properties.myCompanion:FindScriptProperty("lightEffect")
		self.colorPieces = self.properties.myCompanion:FindScriptProperty("colorPieces")
		self.colorEffect = self.properties.myCompanion:FindScriptProperty("colorEffect")
		print(self.properties.myCompanion)
end

function CompanionScript:LookAt(what)
	local compPos = self.properties.myCompanion:GetPosition()
	local lookAtPos = what:GetPosition()
	lookAtPos.z = 125
	
	local movePos = lookAtPos + Vector.New(0, 150, 0)
	
	self.properties.myCompanion:AlterPosition(movePos, 1)
	self.properties.myCompanion:AlterRotation(Rotation.FromVector((lookAtPos - compPos):Normalize()), 0.25)
end

function CompanionScript:ClientOnTick(dt)
	if not self.properties.myCompanion then return end 
	
	if self.properties.pointOfInterest then 
		self:LookAt(self.properties.pointOfInterest)
		
		if not IsServer() then 
			if Vector.Distance(self.properties.myCompanion:GetPosition(), self.properties.pointOfInterest:GetPosition()) < 100 then
				if math.random(1, 1000) == 1000 then
					local sound = self.properties.myCompanion:PlaySound(self.properties.companionGreetingSound[math.random(1,#self.properties.companionGreetingSound)])
					sound:SetPitch(2)
				end
			end
		end
	else 
		self:LookAt(self:GetEntity():GetPlayer())	
	end
end

--[[

function CompanionScript:ClientOnTick(dt)
	if not self.properties.myCompanion then return end 
	

--	print("running on tick..")
	local playerPos = self:GetEntity():GetPlayer():GetPosition() + Vector.New(0,100,0)
	local compPos = self.properties.myCompanion:GetPosition()
	local forward = (self:GetEntity():GetPlayer():GetForward():Normalize()) * 250
	
	playerPos.z = 125	
	
	if self:GetEntity():IsLocal() then 
		--print("poi: ", self.properties.pointOfInterest)
	end
	if self.properties.pointOfInterest then
		local interest = self.properties.pointOfInterest
		local interestPos = interest:GetPosition()
		
		interestPos.z = 125
		forward = interest:GetForward():Normalize() * 350
		interestPos = interestPos + forward
		lerp = self:QuadraticBezier(dt, compPos, interestPos, playerPos) -- 0.005
		face = interest:GetPosition() - compPos
		face = Rotation.Lerp(self.properties.myCompanion:GetRotation(),Rotation.FromVector(face), dt) --.1)
		
		if not IsServer() then 
			if Vector.Distance(compPos, interestPos) < 100 then
				local rand = math.random(1,1000)
				if rand == 1000 then
					local sound = self.properties.myCompanion:PlaySound(self.properties.companionGreetingSound[math.random(1,#self.properties.companionGreetingSound)])
					sound:SetPitch(2)
				end
			end
		end
	else
		playerPos = playerPos + forward
		face = playerPos - compPos
		face = Rotation.Lerp(self.properties.myCompanion:GetRotation(),Rotation.FromVector(face), dt) --.1)
		lerp = Vector.Lerp(compPos, playerPos, dt)-- .02)
	end
	
	local scale = 60
	--print(lerp, dt, scale, lerp * dt * scale)
	if lerp then
		self.properties.myCompanion:SetPosition(lerp)-- * dt * scale)
	end
	
	if face then
		self.properties.myCompanion:SetRotation(face)
	else
		face = Rotation.Lerp(self.properties.myCompanion:GetRotation(), Rotation.Zero, .1)
	end
end

--]]

function CompanionScript:OnTick(dt)

	if not self.playerInterestTriggerScript then return end 
	
	self:ProcessHappiness(dt)
	
	self.properties.pointOfInterest = self.playerInterestTriggerScript.listOfInterests[1]
	
	self:ClientOnTick(dt)
end

function CompanionScript:ProcessHappiness(dt)
	self.properties.companionHappiness = self.properties.companionHappiness - (dt * .09)
	if self.properties.companionHappiness < 0 then
		self.properties.companionHappiness = 1
	end
	local happiness = math.floor(self.properties.companionHappiness)
	if happiness > 90 then
		happiness = "&#xf584;"
	elseif happiness > 80 then
		happiness = "&#xf5b8;"
	elseif happiness > 70 then
		happiness = "&#xf118;"
	elseif happiness > 60 then
		happiness = "&#xf11a;"
	elseif happiness > 50 then
		happiness = "&#xf5a4;"
	elseif happiness > 40 then
		happiness = "&#xf119;"
	elseif happiness > 30 then
		happiness = "&#xf5b4;"
	elseif happiness > 0 then
		happiness = "&#xf5b3;"
	end

	self:GetEntity().companionHappinessWidget.properties.happiness = happiness
end

--Heart Eyes &#xf584; 90-100
--smile beam &#xf5b8; 80-90
--smile regular &#xf118; 70-80
--blank meh &#xf11a; 60-70
--blank no mouth &#xf5a4; 50-60
--frown &#xf119; 40-50
--frown open &#xf57a;
--sad tear &#xf5b4; 30-40
--sad cry &#xf5b3; 0-30

function CompanionScript:FeedCompanion(num, color)
	self:Schedule(function()
		local currentColor = self.colorEffect.assetProperties.color
		local newColor = Color.New(math.min(currentColor.red + math.floor(color.red/5),255), math.min(currentColor.green + math.floor(color.green/5),255), math.min(currentColor.blue + math.floor(color.blue/5),255))
		print("New Color", newColor)
		print("Companion has been fed ", color)
		self.properties.companionHappiness = self.properties.companionHappiness + num
		if self.properties.companionHappiness > 100 then
			self.properties.companionHappiness = 100
		end
		self:SetColorInfluence(newColor)
		self:GetEntity().companionHappinessWidget.properties.recentlyFed = true
		print("Setting to fed - true")
		self:SendToLocal("FeedCompanionLocal")
		Wait(2)
		self:GetEntity().companionHappinessWidget.properties.recentlyFed = false
		local red = newColor.red
		local green = newColor.green
		local blue = newColor.blue

		self.companionData = {red = red, green = green, blue = blue, color = true}
		self:SetSaveData(self.companionData)
		
		print("Saved color")
	end)
end

function CompanionScript:SetColorInfluence(color)
	print("influencing..", color)
	for i=1, #self.colorPieces do
		self.colorPieces[i].color = color
	end
	self.colorEffect.assetProperties.color = color
	print("Setting colors..")

end


function CompanionScript:FeedCompanionLocal()
	self:Schedule(function()
		local sound3 = self.properties.myCompanion:PlaySound2D(self.properties.pickupSound)
		sound3:SetPitch(2)
		Wait(.3)
		local sound2 = self.properties.myCompanion:PlaySound2D(self.properties.companionHappySound)
		sound2:SetPitch(2)		
		Wait(1.3)
		local sound = self.properties.myCompanion:PlaySound2D(self.properties.companionEatSound)
		sound:SetPitch(2)
		sound:SetVolume(.5)
		local forwardface = self.properties.myCompanion:GetForward():Normalize() * 25
		self.properties.myCompanion:PlayEffectAtLocation(self.properties.myCompanion:GetPosition() + forwardface, Rotation.New(math.random(1,360),math.random(1,360),math.random(1,360)),self.properties.companionEatEffect)
		Wait(.5)
		self.properties.myCompanion:PlayEffectAtLocation(self.properties.myCompanion:GetPosition() + forwardface, Rotation.New(math.random(1,360),math.random(1,360),math.random(1,360)),self.properties.companionEatEffect)
		Wait(.7)
	end)
end

function CompanionScript:GetCompanionHappiness()
	return self.properties.companionHappiness
end


function CompanionScript:QuadraticBezier(t,p0,p1,p2)
	local l1 = Vector.Lerp(p0,p1,t)
	local l2 = Vector.Lerp(p1,p2,t)
	local quad = Vector.Lerp(l1,l2,t)
	return quad
end


return CompanionScript
