local SetColourGrading = {}

-- Script properties are defined here
SetColourGrading.Properties = {
	{ name = "colourGrading1", type = "colorgradingasset" },
	{ name = "colourGrading2", type = "colorgradingasset" },
}

--This function is called on the server when this entity is created
function SetColourGrading:SetColourGrading()
	if IsServer() then
		local randomNumber = math.random(1, 16)
		GetWorld().colorGrading = self.properties["colourGrading" .. randomNumber]
	else
		self:GetEntity():SendToServer("SetColourGrading")	
	end
end

return SetColourGrading
