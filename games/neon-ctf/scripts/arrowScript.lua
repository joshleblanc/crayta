local ArrowScript = {}

-- Script properties are defined here
ArrowScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ArrowScript:Init()
	self:GetEntity():AttachTo(self:GetEntity():GetParent(), "head")
end

function ArrowScript:GetUserEntity()
	return self:GetPlayerEntity():GetUser()
end

function ArrowScript:GetPlayerEntity()
	return self:GetEntity():GetParent()
end

function ArrowScript:GetTeam()
	return self:GetUserEntity():FindScriptProperty("team") or 0
end

function ArrowScript:GetDropoff1()
	return GetWorld():Find("flag3")
end

function ArrowScript:GetDropoff2()
	return GetWorld():Find("flag2")
end

function ArrowScript:GetAngle(dest)
	local source = self:GetEntity():GetParent():GetPosition()
	local destination = dest:GetPosition()
	local mid = destination - source
	local rads = math.atan2(mid.z, mid.y)
	return math.deg(rads) - 90
end

function ArrowScript:GetFlag()
	return GetWorld():Find("flag1")
end

function ArrowScript:GetWidget()
	return self:GetEntity().arrowWidget
end

function ArrowScript:SetAngle(angle)
	self:GetWidget().js.arrow.angle = angle
end

function ArrowScript:ShowWidget()
	self:GetWidget():Show()
end

function ArrowScript:HideWidget()
	self:GetWidget():Hide()
end

function ArrowScript:LocalOnTick()
	local userHolding = self:GetFlag():FindScriptProperty("userHolding")
	if userHolding and userHolding:GetPlayer() == self:GetPlayerEntity() then
		self:ShowWidget()
	else
		self:HideWidget()	
	end
	local team = self:GetTeam()
	if team == 1 then
		self:SetAngle(self:GetAngle(self:GetDropoff1()))
	elseif team == 2 then
	 	self:SetAngle(self:GetAngle(self:GetDropoff2()))
	end
end

return ArrowScript
