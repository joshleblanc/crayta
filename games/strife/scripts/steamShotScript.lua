local SteamShotScript = {}

-- Script properties are defined here
SteamShotScript.Properties = {
	-- Example property
	{name = "light", type = "entity",},
}

--This function is called on the server when this entity is created
function SteamShotScript:Init()


end

function SteamShotScript:Smoke()
	if self:GetEntity().active == false then
	self:Schedule(
		function()
			self:GetEntity().active = true
			Wait(.2)
			self:GetEntity().active = false
		
		end)
	end
end

return SteamShotScript
