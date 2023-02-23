local HeroTransportScript = {}

-- Script properties are defined here
HeroTransportScript.Properties = {
	-- Example property
	{name = "transportSound", type = "soundasset",},
}

--This function is called on the server when this entity is created
function HeroTransportScript:Init()
	self:GetEntity().onTriggerEnter:Listen(self, "HandleTriggerEnter")
	self.location = self:FindLocation()
	print("Found location", self.location)
end

function HeroTransportScript:HandleTriggerEnter(player)
	if player:IsA(NPC) then 
		local owner = self.location.properties.owner 
		
		local destination = self:GetEntity().transportOptionScript.properties.template
		local destinationId = destination:GetName()
		
		local heroId = player.heroScript.properties.id
		
		owner:SendToScripts("UseDb", "heroes", function(db)
			db:UpdateOne({ _id = heroId }, {
				_set = {
					currentLocationId = destinationId
				}
			})
		end)
		
		player:Destroy()
		self:GetEntity():PlaySound(self.properties.transportSound)
	end
end

function HeroTransportScript:FindLocation(root)
	root = root or self:GetEntity()
	print("Checking ", root:GetName())
	if root.locationScript then 
		return root.locationScript
	else
		return self:FindLocation(root:GetParent())
	end
end

return HeroTransportScript
