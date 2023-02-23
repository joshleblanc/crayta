local GhostPickupScript = {}

-- Script properties are defined here
GhostPickupScript.Properties = {
	-- Example property
	{ name = "name", type = "string", editable = false },
	{ name = "curseDescription", type = "string", editable = false },
	{ name = "buffDescription", type = "string", editable = false },
	{ name = "curseId", type = "string", editable = false },
	{ name = "buffId", type = "string", editable = false },
	{ name = "range", type = "number", default = 500 },
	{ name = "chest", type = "entity" }
}

local nameDescriptors = {
	"rotting", "broken", "slimy", "old", "ghastly"
}

local names = {
	"artifact", "charm"
}

local buffs = {
	{ id = "range-damage", text = "Your weapons deal more damage" },
	{ id = "fall-damage", text = "You take decreased fall damage" },
	{ id = "health", text = "You have additional health" }
}

local curses = {
	{ id = "range-damage", text = "Your weapons deal less damage" },
	{ id = "fall-damage", text = "You take increased fall damage" },
	{ id = "health", text = "You have reduced health" }
}

--This function is called on the server when this entity is created
function GhostPickupScript:Init()
	self.properties.name = self:GenerateName()
	self:GenerateCharms()
end

function GhostPickupScript:GenerateCharms()
	self:GenerateCurse()
	self:GenerateBuff()
	
	-- if we've generated the same thing for both + and -, regenerate
	if self.properties.buffId == self.properties.curseId then 
		self:GenerateCharms()
	end
end

function GhostPickupScript:ClientInit()
	self.widget = self:GetEntity().ghostPickupWidget
	
	self.widget.js.data.prompt = Text.Format("{interact-icon-raw} Hold to pick up")
	self.widget.js.data.visible = false
	self.widget.js.data.opening = false
	self.properties.chest:PlayAnimation("Closing")
	self.used = false
	--test
	self.localUser = GetWorld():GetLocalUser()
end

function GhostPickupScript:Reset()
	print("Resetting chest")
	self:Init()
	self:SendToAllClients("ClientInit")
	if self.respawnSchedule then 
		self:Cancel(self.respawnSchedule)
		self.respawnSchedule = nil
	end
end

function GhostPickupScript:GenerateBuff()
	local buff = buffs[math.random(1, #buffs)]
	self.properties.buffId = buff.id
	self.properties.buffDescription = buff.text
end

function GhostPickupScript:GenerateCurse()
	local curse = curses[math.random(1, #curses)]
	self.properties.curseId = curse.id
	self.properties.curseDescription = curse.text
end

function GhostPickupScript:GenerateName()
	local descriptor = nameDescriptors[math.random(1, #nameDescriptors)]
	local name = names[math.random(1, #names)]
	return FormatString("{1} {2}", descriptor, name)
end


function GhostPickupScript:ClientOnTick()
	local player = self.localUser:GetPlayer()
	
	if not player or not player.playerScript then return end 
	if self.used then return end
	
	--if player:FindScriptProperty("isGhost") then
	if player.playerScript.properties.isGhost then
		if Vector.Distance(player:GetPosition(), self:GetEntity():GetPosition()) < self.properties.range then 
			player:SendToScripts("SetGhostPickup", self)
			self.widget.js.data.visible = true
			
			-- TEST
				self.widget.js.data.title = self.properties.name
				self.widget.js.data.buff = self.properties.buffDescription
				self.widget.js.data.curse = self.properties.curseDescription
		else
			player:SendToScripts("UnsetGhostPickup", self)
			self.widget.js.data.visible = false
		end	
	else
		self.widget.js.data.visible = false
	end 
	

end

function GhostPickupScript:StartOpening()
	self.widget:CallFunction("StartOpening")
end

function GhostPickupScript:StopOpening()
	self.widget:CallFunction("StopOpening")
end

function GhostPickupScript:Open()
	self.widget.js.data.visible = false 
	self.used = true 
	self.properties.chest:PlayAnimation("Opening")
	
	self.respawnSchedule = self:Schedule(function()
		Wait(60 * 3)
		self:ClientInit()
		self.respawnSchedule = nil
	end)
end

return GhostPickupScript
