local GameControllerScript = {}

-- Script properties are defined here
GameControllerScript.Properties = {
	{ name = "templates", container = "array", type = "template" },
	{ name = "onReset", type = "event" },
	{ name = "afterInit", type = "event" },
	{ name = "floor", type = "entity" }
}

--This function is called on the server when this entity is created
function GameControllerScript:Init()
	self:Schedule(function()
		self.risers = {}
		for i=1,250 do 
			self:SpawnRiser()
		end
		
		Wait()
		self.properties.afterInit:Send()
	end)
	
end

function GameControllerScript:SpawnRiser()
	local width = 5900
	local height = 5900
	local x = math.random() + math.random(-width / 2, width / 2)
	local y = math.random() + math.random(-height / 2, height / 2)
	local template = self.properties.templates[math.random(1, #self.properties.templates)]

	local riser = GetWorld():Spawn(template, Vector.New(x, y, 250), Rotation.Zero)
	--riser:AttachTo(self.properties.floor)
	table.insert(self.risers, riser)
end

function GameControllerScript:StaggeredIterate(iterationsPerSecond, fn)
	for i=1,250 do
		fn(i)
		Wait()
	end
end

function GameControllerScript:TryReset()
	local good = true
	GetWorld():ForEachUser(function(user)
		if user:FindScriptProperty("playing") then
			good = false
		end
	end)
	
	if good then
		self.properties.onReset:Send()
		
		self:Schedule(function()
			for i, v in ipairs(self.risers) do
				v:Destroy()
			end
			Wait(timeToReset)
			self:Init()
			Wait(1)
			self.properties.afterInit:Send()
		end)
	end
end

return GameControllerScript
