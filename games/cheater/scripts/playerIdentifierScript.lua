local PlayerIdentifierScript = {}

-- Script properties are defined here
PlayerIdentifierScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function PlayerIdentifierScript:LocalInit()
	
	local user = GetWorld():GetLocalUser()
	print(user:GetUsername(), "Local user")
	print(self:GetEntity():GetParent():GetUser():GetUsername(), "Parent")
	if user == self:GetEntity():GetParent():GetUser() then
		self:GetEntity().visible = true
		print("THIS IS TRUE")
	else
		self:GetEntity().visible = false
		print("THIS IS FALSE")
	end
end

return PlayerIdentifierScript
