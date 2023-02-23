local UserSinglePlayerScript = {}

-- Script properties are defined here
UserSinglePlayerScript.Properties = {
	-- Example property
	{name = "numberOfItemsToCollect", type = "number", default = 10},
	{name = "collected", type = "number", editable = false, default = 0},
	{name = "singlePlayerMode", type = "boolean", editable = false},
	
}

--This function is called on the server when this entity is created
function UserSinglePlayerScript:Init()
	self.time = 0
end


-- track whether we are in single player mode.
function UserSinglePlayerScript:SinglePlayerMode(bool)
	self.properties.singlePlayerMode = bool
	print("SinglePlayer Mode User")
end

-- When something is colleceted - add it to the collection.
function UserSinglePlayerScript:Collected()
	self.properties.collected = self.properties.collected + 1
	
	if self.properties.collected == self.properties.numberOfItemsToCollect then
		self:EndSinglePlayerGame()
		self.properties.singlePlayerMode = false
		print(self.time)
		Print("You Win")
		self.time = 0
	end
end

function UserSinglePlayerScript:EndSinglePlayerGame()
	self.properties.trackingTime = false
	self:ProcessResults()
	self.properties.collected = 0
	
end

function UserSinglePlayerScript:ProcessResults()
	
end


function UserSinglePlayerScript:OnTick(dt)
	if self.properties.singlePlayerMode then
		self.time = self.time + dt
	end
end

return UserSinglePlayerScript
