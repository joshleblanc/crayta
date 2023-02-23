local SystemMalfunctionScript = {}

-- Script properties are defined here
SystemMalfunctionScript.Properties = {
	-- Example property
	{name = "hinderedVision1", type = "postprocessasset"},
	{name = "hinderedVision2", type = "colorgradingasset"},
	{name = "defaultVision", type = "postprocessasset"},
	{name = "defaultGrading", type = "colorgradingasset"},
	{name = "malfunctionSound", type = "soundasset"},
	{name = "fixSound", type = "soundasset"},
	
}

--This function is called on the server when this entity is created
function SystemMalfunctionScript:ClientInit()
	self.timeBetweenCollecting = 15
	self:Reset()
	self.visionAffected = false
	
end

function SystemMalfunctionScript:Collected()
	if IsServer() then
		self:SendToLocal("Collected")
	else
		self.timeBetweenCollecting = 15
		self:Reset()
	end
	
end

function SystemMalfunctionScript:Reset()
	if self.visionAffected then
		self:Schedule(
			function()
				self.visionAffected = false
				local text = "Rebooting systems.."
				self:GetEntity():GetUser():SendToScripts("DoScreenFade",0,0,text)
				self.timeBetweenCollecting = 15
				GetWorld().postProcess = self.properties.defaultVision
				GetWorld().colorGrading = self.properties.defaultGrading
				self:GetEntity():PlaySound2D(self.properties.fixSound)
				self:GetEntity():GetUser():SendToScripts("ApplyToUser")
				local scoreboard = self:GetEntity():GetUser():FindWidget("scoreboardWidget")
				scoreboard:Show()
				self.visionAffected = false
		end)
	end
end

function SystemMalfunctionScript:MalfunctionVision()
self:Schedule(
	function()
		self.visionAffected = true
		local text = "System malfunctioning.. collect parts!"
		self:GetEntity():GetUser():SendToScripts("DoScreenFade",3,1,text)
		local scoreboard = self:GetEntity():GetUser():FindWidget("scoreboardWidget")
		
		self:GetEntity():PlaySound2D(self.properties.malfunctionSound)
		for i=1, 2 do
			Wait(.1)	
			scoreboard:Hide()
			Wait(.2)
			scoreboard:Show()
			Wait(.1)
			scoreboard:Hide()
		end
			if self.visionAffected == true then
				--GetWorld().postProcess = self.properties.hinderedVision1
				--GetWorld().colorGrading = self.properties.hinderedVision2
				self:GetEntity():SendToScripts("ApplyToUser",self:GetEntity():GetUser())
				self:GetEntity():PlaySound2D(self.properties.malfunctionSound)
			else
				self:Reset()
			end
		
		end)
end

function SystemMalfunctionScript:ChooseMalfunction()
	local malfunctions = {
	"MalfunctionVision"
	}
	local rand = math.random(#malfunctions)
	self:SendToScript(malfunctions[rand])
	
end


function SystemMalfunctionScript:ClientOnTick(dt)
	if self.timeBetweenCollecting > 0 then
		self.timeBetweenCollecting = self.timeBetweenCollecting - dt
	end
	
	if self.timeBetweenCollecting < 5 and self.visionAffected == false then
		--self:ChooseMalfunction()
	end
end


return SystemMalfunctionScript
