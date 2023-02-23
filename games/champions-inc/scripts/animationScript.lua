local AnimationScript = {}

-- Script properties are defined here
AnimationScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
}

--This function is called on the server when this entity is created
function AnimationScript:Init()
	self:GetEntity():PlayAnimationLooping("idle_aggressive")
end

--[[
"idle_neutral"
"idle_aggressive"
"slam"
"slam_start"
"slam_loop"
"slam_end"
"swipe"
"swipe_start"
"swipe_loop"
"swipe_end"
--]]

return AnimationScript
