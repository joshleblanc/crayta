local UserSideScrollerScript = {}

-- Script properties are defined here
UserSideScrollerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function UserSideScrollerScript:Init()
	--self:GetEntity():GetUser():SetMoveOverride(Vector2D.New(1, 0), Vector2D.Zero)
end

-- hope this isn't expensive...
function UserSideScrollerScript:OnTick()
	if self:GetEntity():GetUser() then 
		self:GetEntity():GetUser():SetMoveOverride(Vector2D.New(1, 0), Vector2D.Zero)
	end
end

function UserSideScrollerScript:LocalOnTick()
	if self:GetEntity():GetUser() then 
		self:GetEntity():GetUser():SetMoveOverride(Vector2D.New(1, 0), Vector2D.Zero)
	end
	
end

return UserSideScrollerScript
