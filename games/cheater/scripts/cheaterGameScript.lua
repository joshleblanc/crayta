local CheaterGameScript = {}

-- Script properties are defined here
CheaterGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "camera", type = "entity" },
	{ name = "numObjectives", type = "number", default = 3 },
}

--This function is called on the server when this entity is created
function CheaterGameScript:Init()
	self.desks = GetWorld():FindAllScripts("deskScript")
	self.game = GetWorld():FindScript("gameScript")
end

function CheaterGameScript:HandleEnd()
	self.running = false
	print("Handling end")
	for _, desk in ipairs(self.desks) do 
		desk:Deactivate()
	end
end

function CheaterGameScript:OnTick()
	if not self.running then return end 
	
	local finishEarly = true
	self.game:ForEachUser(function(user)
		local player = user:GetPlayer()
		if player and player:IsAlive() then
			finishEarly = false
		end
	end)
	if finishEarly then 
		self.game:EndPlay()
	end
end

function CheaterGameScript:HandleStart(gameScript)
	print("handling start")
	self.running = true
	local numUsers = 1 --#gameScript:GetUsers()
	local numChosen = 0
	
	local availDesks = { unpack(self.desks) }
	
	for _, desk in ipairs(availDesks) do 
		if not desk.isSpawn then 
			desk:Deactivate()
		end
		
		if math.random() < 0.1 then 
			desk:AddObstruction()
		end
	end
	
	local options = { unpack(self.desks) }
	local objectives = {}
	
	while #objectives < self.properties.numObjectives do 
		local optionIndex = math.random(1, #options)
		local option = options[optionIndex]
		if not option.isSpawn then 
			table.remove(options, optionIndex)
			table.insert(objectives, option)
		end
	end

	
	gameScript:ForEachUser(function(user)
		user.userCheaterScript:SetObjectives(objectives)
		user.userCheaterScript:ShowCurrentObjective()
	end)
end

return CheaterGameScript
