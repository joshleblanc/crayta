local HudScript = {} 

HudScript.Properties = {
}

function HudScript:LocalInit()

	self.timerWidget = self:GetEntity().timerWidget
	self.timerWidget.visible = false
end

function HudScript:ShowHud(params)

	if not self:GetEntity():IsLocal() then
		self:SendToLocal("ShowHud", params)	
		return
	end
	
	-- if totalTime is zero the round will last forever so don't display...
	if params.totalTime == 0 then
		return
	end
	self.startTime = params.startTime
	self.totalTime = params.totalTime
	if not self.hudTask then
		self.hudTask = self:Schedule(
			function()
				while true do
					Wait(0.5)
					self:UpdateTimer()
				end
			end
		)
	end
	self:UpdateTimer()
	self.timerWidget.visible = true
end

function HudScript:HideHud()
	print("HIDING HUD")
	if not self:GetEntity():IsLocal() then
		self:SendToLocal("HideHud")	
		return
	end
	
	self.timerWidget.visible = false
	if self.hudTask then
		self:Cancel(self.hudTask)
		self.hudTask = nil
	end
end

function HudScript:UpdateTimer()
	self.timerWidget.properties.time = Text.FormatTime("{mm}:{ss}", math.max(self.startTime + self.totalTime - GetWorld():GetServerTime(), 0.0))
end

return HudScript
