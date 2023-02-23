local PlayerLocationScript = {}

-- Script properties are defined here
PlayerLocationScript.Properties = {
	-- Example property
	{ name = "location", type = "text", editable = false },
	{ name = "floor", type = "number", default = 1, editable = false },
	{ name = "onFloorChange", type = "event" }
}

function PlayerLocationScript:SetLocation(location)
	self.properties.location = Text.Format(location)
end

function PlayerLocationScript:SetFloor(f)
	self.properties.floor = f
	self.properties.onFloorChange:Send(self:GetEntity(), f)
end

return PlayerLocationScript
