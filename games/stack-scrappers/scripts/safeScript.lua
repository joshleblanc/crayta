local SafeScript = {}

-- Script properties are defined here
SafeScript.Properties = {
	-- Example property
	{name = "safe", type = "boolean", default = false, editable = false},
	{name = "safeStack", type = "entity", editable = false},
}

--This function is called on the server when this entity is created
function SafeScript:Init()
	
end

function SafeScript:InSafeArea(trainStack)
	self.properties.safe = true
	self.properties.safeStack = trainStack
end

function SafeScript:OutOfSafeArea()
	self.properties.safe = false
	self.properties.safeStack = nil
end


function SafeScript:ProcessSafety()
	if self.properties.safeStack then
		local result, bool = self.properties.safeStack.TrainShellScript:CheckStack(self:GetEntity())
		return result, bool
	end
end

return SafeScript
