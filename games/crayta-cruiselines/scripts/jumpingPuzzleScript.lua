local JumpingPuzzleScript = {}

-- Script properties are defined here
JumpingPuzzleScript.Properties = {
	-- Example property
	{ name = "id", type = "string" },
	{ name = "name", type = "string" },
	{ name = "reward", type = "number" }
}

function JumpingPuzzleScript:Init()
	
end

function JumpingPuzzleScript:ClientInit()
	self.used = false
	self.lastUsedTime = nil
end

function JumpingPuzzleScript:ClientOnTick()
	if not self.lastUsedTime then return end 
	
	if GetWorld():GetTimeOfDay() < self.lastUsedTime then
		print("Resetting")
		self.used = false
	end
end

function JumpingPuzzleScript:DoServerStuff(player)
	local user = player:GetUser()
	user:SendToScripts("AddMoney", self.properties.reward, FormatString("You completed the {1} jumping puzzle!", self.properties.name), true)
	user:SendXPEvent("complete-jumping-puzzle", { id = self.properties.id })
end

function JumpingPuzzleScript:DoClientStuff(player)
	print("Doing client stuff")
	local user = player:GetUser()
	if user ~= GetWorld():GetLocalUser() then return end 
	
	print("Found user", self.used, self.lastUsedTime)
	
	if self.used then
		user:SendToScripts("Shout", "You've already completed this today")
	else
		self.used = true
		self.lastUsedTime = GetWorld():GetTimeOfDay()
		
		self:SendToServer("DoServerStuff", player)
	end
end

function JumpingPuzzleScript:OnTriggerEnter(player)
	local user = player:GetUser()
	self:SendToAllClients("DoClientStuff", player)
end

function JumpingPuzzleScript:GetId()
	return FormatString("jumping-puzzle-{1}", self.properties.id)
end

return JumpingPuzzleScript
