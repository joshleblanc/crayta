local OilSlickScript = {}

-- Script properties are defined here
OilSlickScript.Properties = {
	-- Example property
	{name = "slowSound", type = "entity" }
}

--This function is called on the server when this entity is created
function OilSlickScript:Init()
end

function OilSlickScript:OnTriggerEnter(player)
	if player:IsA(Character) then
		player:SendToScripts("EnterOilSlick")
		player:GetUser():SendToScripts("DoOnLocal", self:GetEntity(), "PlaySound")
	end
end

function OilSlickScript:PlaySound()
	self:Schedule(function()
	self.properties.slowSound.active = true
	Wait(2)
	if self.properties.slowSound.active == true then
		self.properties.slowSound.active = false
	end
	end)
end

function OilSlickScript:StopSound()
	self.properties.slowSound.active = false
end

function OilSlickScript:OnTriggerExit(player)
	if player:IsA(Character) then
		player:SendToScripts("ExitOilSlick")
		player:GetUser():SendToScripts("DoOnLocal", self:GetEntity(), "StopSound")
	end
end


return OilSlickScript
