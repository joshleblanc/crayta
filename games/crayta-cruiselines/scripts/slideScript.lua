local SlideScript = {}

-- Script properties are defined here
SlideScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function SlideScript:Init()
end

function SlideScript:OnTriggerEnter(player)
	if player:IsAlive() then
		self:StartSlideSchedule(player)
	end
end

function SlideScript:StartSlideSchedule(player)
	self:Schedule(function()
		player:Launch(Vector.New(200,0,100))
		Wait()
		player:SetAlive(false)
		Wait(5)
		player:SetAlive(true)
	end)
end

return SlideScript
