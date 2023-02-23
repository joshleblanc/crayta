local WarningExitScript = {}

-- Script properties are defined here
WarningExitScript.Properties = {
	-- Example property
	{name = "warningSound", type = "soundasset"},
}

--This function is called on the server when this entity is created
function WarningExitScript:Init()
end

function WarningExitScript:OnTriggerEnter(player)
	self:Schedule(
	function()
		local text = "WARNING: This portal exits the game to the voting area!"
		for i = 1, 3 do 
			player:GetUser():SendToScripts("PlaySoundLocally",self.properties.warningSound)
			Wait(.2)
		end
		player:GetUser():SendToScripts("Shout",text,5)
	end)
end
return WarningExitScript
