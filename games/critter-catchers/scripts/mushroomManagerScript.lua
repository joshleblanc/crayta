local MushroomManagerScript = {}

-- Script properties are defined here
MushroomManagerScript.Properties = {
	-- Example property
}

--This function is called on the server when this entity is created
function MushroomManagerScript:Init()
	self.mushroomTable = self:GetEntity():GetChildren()
	self:ManageMushrooms()
end

function MushroomManagerScript:ManageMushrooms()
	self:Schedule(function()
		while true do
			local rand = math.random(1,#self.mushroomTable)
			self.mushroomTable[rand]:SendToScripts("ActivateMushroom")
			Wait(2)
		end
	end)

end



return MushroomManagerScript
