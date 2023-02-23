local StartScreenScript = {}

-- Script properties are defined here
StartScreenScript.Properties = {
	-- Example property
	{name = "startCam", type = "entity"},
}

--This function is called on the server when this entity is created
function StartScreenScript:Init()
	
end

function StartScreenScript:LocalInit()
	self.widget = self:GetEntity().startScreenWidget
	self:Schedule(function()
		Wait(20)
		self.widget:CallFunction("Start")
		Wait(1)
		self.widget.visible = false
		self:GetEntity().companionScript:StartLocal()
	end)
end

function StartScreenScript:OnUserLogin(user)
	user:SetCamera(self.properties.startCam)
end

return StartScreenScript
