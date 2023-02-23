local EntranceScript = {}

-- Script properties are defined here
EntranceScript.Properties = {
	-- Example property
	{name = "npcChar", type = "entity"},
	{name = "emotes", type = "emoteasset", container = "array"},
}

--This function is called on the server when this entity is created
function EntranceScript:Init()
end

function EntranceScript:OnTriggerEnter(player)
	if player:IsA(Character) then
		print(self.properties.npcChar, "NPC")
		local fame = player:GetUser().userStatsScript:Fame() 
		print (fame .. " Fame")
		if fame == 0 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[1])
		elseif fame >= 1 and fame <= 10 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[2])
		elseif fame >= 11 and fame <= 20 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[3])
		elseif fame >= 21 and fame <= 30 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[4])
		elseif fame >= 31 and fame <= 40 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[5])
		elseif fame >= 41 and fame <= 50 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[6])
		elseif fame >= 51 and fame <= 60 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[7])
		elseif fame >= 61 and fame <= 70 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[8])
		elseif fame >= 71 and fame <= 80 then
			self.properties.npcChar:PlayEmote(self.properties.emotes[9])
		end
	end
end

return EntranceScript
