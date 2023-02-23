local GridScript = {}

-- Script properties are defined here
GridScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "blocks", type = "entity" },
	{ name = "camera", type = "entity" },
	{ name = "arena", type = "entity" },
	{ name = "spawnEffect", type = "effectasset" }
}

--This function is called on the server when this entity is created
function GridScript:Init()
end

function GridScript:OnUserLogin(user)
	user:SetCamera(self.properties.camera)
end

function GridScript:SetArena(set)
	print("Setting arena")
	self.properties.arena:SetPosition(Vector.New(0, 0, -10000))
	self.properties.blocks:SetPosition(Vector.New(0, 0, -10000))
	
	self.properties.blocks = set.properties.blocks
	self.properties.arena = set.properties.arena
	
	self.properties.arena:SetPosition(Vector.New(0, 0, 0))
	self.properties.blocks:SetPosition(Vector.New(0, 0, 0))
end

function GridScript:ClientInit()
	self.grid = {}
	self.size = 10 * 25
end

function GridScript:HandleUpdate(grid)
	self.grid = grid
	--self:UpdateGrid()
end

function GridScript:HandleSpawn(row, col)
	self:GetEntity():PlayEffectAtLocation(self:WorldPos(row, col), Rotation.Zero, self.properties.spawnEffect)
end

function GridScript:HandleStart(board)
	print("Starting", self.properties.blocks:GetName())
	self.grid = board
	self.blocks = self.properties.blocks:GetChildren()
	self.arena = self.properties.arena
	self.arena:SetPosition(Vector.New(0, 0, 0))
	self.properties.blocks:SetPosition(Vector.New(0, 0, 0))
	self.properties.arena:SendToScripts("_ClientApplySettings")
	self.properties.arena:SendToScripts("SetActiveOn")
	self.properties.arena:SendToScripts("SetVisibilityOn")
	
	print("HandleStart: UpdatingGrid")
	self:UpdateGrid()
end

function GridScript:HandleStop()
	print("Stopping")
	self.arena:SetPosition(Vector.New(0, 0, -10000))
	self.properties.blocks:SetPosition(Vector.New(0, 0, -10000))
	self.properties.arena:SendToScripts("SetActiveOff")
	self.properties.arena:SendToScripts("SetVisibilityOff")
end

function GridScript:ClientOnTick()
	--self:UpdateGrid()
end

function GridScript:MoveCell(data)
	print("MoveCell: Running")
	local currX, currY, newX, newY
	if data.axis == "row" then
		currX = data.row
		currY = data.col
		newX = data.row
		newY = data.newCol
	else
		currX = data.col
		currY = data.row
		newX = data.newCol
		newY = data.row
	end
	
	print("Finding block", currX, currY)
	local block = self:FindBlock(currX, currY)
	local overlappingBlock = self:FindBlock(newX, newY)
	if not block then
		return 
	end
	
	if block == overlappingBlock then return end 
	
	block:SendToScripts("Show")
	--block:SendToScripts("HideNumber", 0.1)
	--overlappingBlock:SendToScripts("SetNumber", data.newValue)
	block:SendToScripts("PlayMoveSound")
	--block:SendToScripts("SetPos", newX, newY)
	self:Schedule(function()
		Wait()
		Wait(block:PlayTimeline(
			0, self:WorldPos(currX, currY),
			0.1, self:WorldPos(newX, newY)
		))
		print("MoveCell: UpdateGrid")
		self:UpdateGrid()
	end)
end

function GridScript:HideGrid()
	print("Hiding grid")
	for _, block in ipairs(self.blocks) do
		block:SendToScripts("Hide")
	end
end

function GridScript:WorldPos(x, y)
	local a = (x * self.size) - (4 * self.size / 2) - 125
	local b = (y * self.size) - (4 * self.size / 2) - 125
	local c = 175
	
	return Vector.New(a, b, c)
end

function GridScript:FindBlock(x, y, num)
	for _, block in ipairs(self.blocks) do
		if block.blockScript:IsA(x, y, num) then
			return block
		end
	end
	
	for _, block in ipairs(self.blocks) do
		if block.blockScript:IsAvailable() then
			return block
		end
	end
	
	return nil
end

function GridScript:UpdateGrid()
	local user = GetWorld():GetLocalUser()
	print(user.userStatScript:GetLevelPercent(), user.userStatScript:Level())
	local grid = self.grid
	local blockIndex = 1
	for i, row in ipairs(grid) do
		for j, col in ipairs(row) do
			local block = self:FindBlock(i, j)
			if col > 0 then 
				block:SetPosition(self:WorldPos(i, j))
				block:SendToScripts("SetNumber", grid[i][j])
				print("Setting number", i, j, grid[i][j], block:GetName())
				block:SendToScripts("SetPos", i, j)
				block:SendToScripts("Show")
			else
				block:SendToScripts("Hide")
			end
			
		end
	end
	
	for _, block in ipairs(self.blocks) do
		if block.blockScript:IsAvailable() then
			block:SendToScripts("Hide")
		end
	end
end



return GridScript
