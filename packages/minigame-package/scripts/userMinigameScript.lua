local UserMinigameScript = {}

-- Script properties are defined here
UserMinigameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

function UserMinigameScript:ClientInit()
	-- this was erroring, so we're going ot wait for the widget to be available
	self:Schedule(function()
		self.widget = self:GetEntity().userMinigameWidget
		while not self.widget do
			Wait()
			self.widget = self:GetEntity().userMinigameWidget
		end
		print("Widget found")
		self.widget.js.data.instructions = Text.Format("Press {1} inside the red area", "{jump-icon-raw}")
	end)
end

function UserMinigameScript:Start(difficulty, mode, callback)
	self.callback = callback
	self:GetEntity():GetPlayer():SetInputLocked(true)
	self.widget:Show()
	self.widget:CallFunction("Start", difficulty, mode)
end

function UserMinigameScript:StartSync(difficulty, mode)
	
	local result, pos, accuracy
	
	self:Start(difficulty, mode, function(a, b, c)
		print("Done inside", result, pos, accuracy)
		result = a
		pos = b
		accuracy = c
	end)
	
	while result == nil do
		Wait()
	end
	
	print("Done", result, pos, accuracy)
	return result, pos, accuracy
end

function UserMinigameScript:Finish(result, pos, accuracy)
	self.widget:Hide()
	self:GetEntity():GetPlayer():SetInputLocked(false);
	
	if self.callback then
		self.callback(result, pos, accuracy)
	end
end

return UserMinigameScript
