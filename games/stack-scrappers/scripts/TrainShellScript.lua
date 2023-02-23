local TrainShellScript = {}

-- Script properties are defined here
TrainShellScript.Properties = {
	-- Example property
	{name = "topShellEntity", type = "entity"},
	{name = "middleShellEntity", type = "entity"},
	{name = "numOfShells", type = "number", default = 3, editable = false},
	{name = "bottomSafeShellTrigger", type = "entity"},
	{name = "bottomShellEntity", type = "entity"},
	{name = "bottomShellVM", type = "entity"},
	{name = "light1", type = "entity"},
	{name = "light2", type = "entity"},
}

--This function is called on the server when this entity is created
function TrainShellScript:Init()
end

function TrainShellScript:PlayerEntered(player)
	print("player is safe")
	player.SafeScript:InSafeArea(self:GetEntity())
end

function TrainShellScript:PlayerExited(player)
	print("player is not safe")
		if player:IsValid() and player.SafeScript then
			player.SafeScript:OutOfSafeArea()
		end
end

function TrainShellScript:CheckStack(player)
	if self.properties.numOfShells == 3 then
		self.properties.numOfShells = self.properties.numOfShells -1
		return self.properties.topShellEntity
	elseif self.properties.numOfShells == 2 then
		self.properties.numOfShells = self.properties.numOfShells -1
		self.properties.light1.color = Color.New(255,0,0)
		self.properties.light2.color = Color.New(255,0,0)
		
		return self.properties.middleShellEntity
	elseif self.properties.numOfShells == 1 then
		self.properties.numOfShells = self.properties.numOfShells -1
		self.properties.bottomShellVM:SendToScripts("Destroy")
		return self.properties.bottomShellEntity , true
	end
end


return TrainShellScript
