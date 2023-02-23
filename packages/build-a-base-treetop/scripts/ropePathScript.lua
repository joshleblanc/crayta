local RopePathScript = {}

-- Script properties are defined here
RopePathScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "points", type = "entity", container = "array" },
	{ name = "ropeTemplate", type = "template" },
	{ name = "update", type = "boolean", default = false, tooltip = "Check this to re-build the path on a schedule. Useful if any of the points in the path move" },
	{ name = "completePath", type = "boolean", default = false, tooltip = "Connect the last point to the first point" },
	{ name = "ropeLength", type = "number", default = 95, editable = false }
}

--This function is called on the server when this entity is created
function RopePathScript:Init()
	self.ropes = {}
	self:CreatePath()
end

function RopePathScript:StopRopePathUpdate()
	self.properties.update = false
end

function RopePathScript:OnTick()
	if not self.properties.update then return end 
	
	local ropeCount = #self.ropes
	self:CreatePath()
	
	-- We only need to update the client if we've spawned a rope
	-- sending it every frame is just a waste of network bandwidth
	if #self.ropes ~= ropeCount then
		self:SendToAllClients("UpdateClientRopes", self.ropes)
	end
	
end

function RopePathScript:ClientOnTick()
	if not self.properties.update then return end 
	
	self:CreatePath()
end

function RopePathScript:ClientInit()
	self.ropes = {}
end

function RopePathScript:UpdateClientRopes(ropes)
	self.ropes = ropes
end

function RopePathScript:CreatePath()	
	local first
	local last
	self.ropeCount = 1

	for i=1,#self.properties.points do 	
		if first == nil then
			first = self.properties.points[i]
		else
			last = self.properties.points[i]
			
			self:LinkPoints(first, last)
			
			first = last
		end
	end
	
	if self.properties.completePath then
		self:LinkPoints(self.properties.points[#self.properties.points], self.properties.points[1])
	end
	
	-- If we've previously spawned ropes that are no longer in the path, 
	-- hide them.
	-- This originally destroyed them, switched to hide to try and find a performance problem
	for i=self.ropeCount, #self.ropes do
		if self.ropes[i] and self.ropes[i]:IsValid() then
			self.ropes[i].visible = false
		end
	end
end

function RopePathScript:LinkPoints(first, last)
	local lastPosition = last:GetPosition()
	local firstPosition = first:GetPosition()
	
	local distance = Vector.Distance(lastPosition, firstPosition)
	local direction = (lastPosition - firstPosition):Normalize()
	local rotation = Rotation.FromVector(direction)
	local numRopes = math.floor(distance / self.properties.ropeLength) - 1
	
	-- Depending on where the start/end anchors are, this could cause a gap between the anchor and the rope
	-- So we're going to spawn an extra rope at the endpoint itself
	self:CreateRope(lastPosition - (direction * self.properties.ropeLength), rotation)

	for i=0,numRopes do
		local pos = firstPosition + (direction * self.properties.ropeLength * i)
		self:CreateRope(pos, rotation)
	end
end

function RopePathScript:CreateRope(position, rotation)
	if self.ropes[self.ropeCount] and self.ropes[self.ropeCount]:IsValid() then
		local rope = self.ropes[self.ropeCount]
		rope:SetPosition(position)
		rope:SetRotation(rotation)
		rope.visible = true
	elseif IsServer() then 
		local rope = GetWorld():Spawn(self.properties.ropeTemplate, position, rotation)
		rope:AttachTo(self:GetEntity())
		rope:SetPosition(position)
		rope:SetRotation(rotation)
		self.ropes[self.ropeCount] = rope
	end
	self.ropeCount = self.ropeCount + 1
end

return RopePathScript
