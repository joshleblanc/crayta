local UserRunScript = {}

-- Script properties are defined here
UserRunScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "rooms", type = "template", container = "array" },
	{ name = "startRoom", type = "template" },
	{ name = "startOutput", type = "template" },
}

--This function is called on the server when this entity is created
function UserRunScript:Init()
	self:Reset()
end

function UserRunScript:Reset()
	self.currentNode = {
		depth = 1,
		room = self.properties.startRoom,
		outputs = {	
			out = {
				destination = {
					room = self.properties.startOutput,
					outputs = {}
				}
			}
		}
	}
	self.root = self.currentNode
end

function UserRunScript:StartRun()
	self.currentNode = self.root
end

function UserRunScript:SpawnRoom(doorScript)
	if self.spawning then return end 
	
	self.spawning = true
	-- currentNode is the current room you're actively in right this second
	
	self:GetEntity():SendToScripts("DoScreenFadeOut", 1)
	local output = self.currentNode.outputs[doorScript.properties.id]
	local destination = output.destination
	local roomTemplate = output.destination.room

	local room = GetWorld():Spawn(roomTemplate, Vector.Zero, Rotation.Zero)
	local doors = room:FindScriptProperty("outputs")-- these are the doors in the room you're _going_ to

	--table.insert(doors, roomTemplate:FindScriptProperty("input"))
	
	print(room:FindScriptProperty("input"))
	
	if not output.spawn then 
		output.spawn = room:FindScriptProperty("input"):FindScriptProperty("id")
	end
	
	function wireOutputs(door)
		print("Checking door", self.currentNode.outputs[door.properties.id])
		if not destination.outputs[door.properties.id] then 
			print("Setting output for", door.properties.id)
			if door.properties.id == output.spawn then -- if this is the door we're going to, link it back to us
				print("We matched the spawn door in the destination location")
				destination.outputs[door.properties.id] = {
					destination = self.currentNode,
					spawn = doorScript.properties.id
				}
			else  -- if this is just a random door in the room, generate the room it links to. 
				if door.properties.to then 
					destination.outputs[door.properties.id] = {
						destination = {
							room = door.properties.to,
							outputs = {},
						}
					}
				else 
					destination.outputs[door.properties.id] = {
						destination = self:GenerateRoom()
					}
				end
				
			end
		end
	end
	
	print("iterating doors", #doors)
	for i=1,#doors do 
		local door = doors[i].roomDoorScript
		wireOutputs(door)
	end
	
	wireOutputs(room:FindScriptProperty("input").roomDoorScript)
	
	room:Destroy()

	-- set out node in the tree to the new location
	print("Setting current node to", doorScript.properties.id)
	
	local lastNode = self.currentNode 
	
	self.currentNode = self.currentNode.outputs[doorScript.properties.id].destination
	self.currentNode.depth = lastNode.depth + 0.1
	
	self:GetEntity():SendToScripts("GoTo", output.destination.room, output.spawn)
	
	self.spawning = false 
--	self:GetEntity():SendToScripts("PrintTable", self.root)
	
	--[[
	if not destination.entity then 
		
		local door = doors[math.random(1, #doors)]:GetEntity()
		local doorRoom = doorScript:FindRoom()
		room:AttachTo(doorRoom)
		
		local rotDiff = door:GetRotation() - doorScript:GetEntity():GetRotation()
		
		room:SetRelativeRotation(rotDiff + Rotation.New(0, 180, 0))
		room:SetRelativePosition(door:GetRelativePosition())
		
		destination.entity = room
	end
	]]--
end

function UserRunScript:GenerateRoom()
	local room = self:GetRandomRoom()
	
	if self.currentNode then 
		while room == self.currentNode.room do 
			room = self:GetRandomRoom()
		end
	end

	local node = {
		room = room,
		outputs = {}
	}
	
	return node
end

function UserRunScript:GetRandomRoom()
	local room = self.properties.rooms[math.random(1, #self.properties.rooms)]
	return room
end

return UserRunScript
