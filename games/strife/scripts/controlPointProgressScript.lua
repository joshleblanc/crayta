local ControlPointProgressScript = {}

-- Script properties are defined here
ControlPointProgressScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function ControlPointProgressScript:Init()
	self.controlPoint = self:GetEntity():GetParent().controlPointScript
end

function ControlPointProgressScript:ClientInit()
	self.widget = self:GetEntity().controlPointProgressWidget
end

function ControlPointProgressScript:Reset()
	if IsServer() then 
		self:SendToAllClients("Reset")
		return 
	end

	self.widget:Hide()
end

function ControlPointProgressScript:ShowWidget(player)
	if IsServer() then 
		if not self.controlPoint.properties.canCapture then return end
		if player:FindScriptProperty("isGhost") then return end
		
		self:SendToAllClients("ShowWidget", player)
		return
	end
	
	if player ~= GetWorld():GetLocalUser():GetPlayer() then return end
	
	self.widget:Show()
end

function ControlPointProgressScript:HideWidget(player)
	if IsServer() then 
		if not self.controlPoint.properties.canCapture then return end
		if player and player:FindScriptProperty("isGhost") then return end
		
		self:SendToAllClients("HideWidget", player)
		return
	end
	
	if player ~= GetWorld():GetLocalUser():GetPlayer() then return end
	
	self.widget:Hide()
end

function ControlPointProgressScript:OnTick()
	self:SendToAllClients("AdjustWidget", 
		self.controlPoint.properties.name, 
		self.controlPoint.properties.owner, 
		self.controlPoint.properties.capturingTeam, 
		self.controlPoint.scores
	)
end

function ControlPointProgressScript:AdjustWidget(name, owner, capturingTeam, scores)
	if scores[capturingTeam] == 0 then 
		self.widget.js.data.team = owner
		self.widget.js.data.progress = FormatString("{1}%", scores[owner])
		self.widget.js.data.name = name
		
	else 
		self.widget.js.data.team = capturingTeam
		self.widget.js.data.progress = FormatString("{1}%", scores[capturingTeam])
		self.widget.js.data.name = name
	end
end

return ControlPointProgressScript
