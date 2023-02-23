local SetPostProcess = {}

-- Script properties are defined here
SetPostProcess.Properties = {
	{ name = "postProcess1", type = "postprocessasset" },
	{ name = "postProcess2", type = "postprocessasset" },
}


function SetPostProcess:SetPostProcess()
	if IsServer() then
		local randomNumber = math.random(1,2)
		GetWorld().postProcess = self.properties["postProcess" .. randomNumber]
	else
		self:GetEntity():SendToServer("SetPostProcess")
	end
end

return SetPostProcess
