local UserHeroSelectScript = {}

-- Script properties are defined here
UserHeroSelectScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "heroSelect", type = "entity", editable = false }
}

--This function is called on the server when this entity is created
function UserHeroSelectScript:Init()
	self.npcs = {}
end

function UserHeroSelectScript:SelectHero(cb, filter)
	self.cb = cb
	self.filter = filter
	self:RunHeroSelect(self.properties.heroSelect.heroSelectScript)
end

function UserHeroSelectScript:SetHeroSelect(entity)
	self.properties.heroSelect = entity
end

function UserHeroSelectScript:RunHeroSelect(script)
	self.running = true
	self.heroSelectScript = script 
	
	self.heroes = {} 
	local tmp = self:GetEntity().userHeroesScript:GetHeroes()
	
	for _, hero in ipairs(tmp) do 
		if self.filter and self.filter(hero) then 
			table.insert(self.heroes, hero)
		elseif not self.filter then 
			table.insert(self.heroes, hero)
		end
	end
	
	if #self.heroes == 0 then 
		self.currIndex = 0
		self:FinishHeroSelection()
		return
	end
	
	self.currIndex = 1
	
	self:GetEntity():SetCamera(script.properties.camera)
	
	self:ShowHero(self.heroes[self.currIndex], 1)
	
	self:GetEntity():GetPlayer():SetInputLocked(true)
	
	self:GetEntity().userRoomScript:OpenDetails({ mode = "select" })
end

function UserHeroSelectScript:TrackNpc(npc)
	local newArr = { npc }
	
	for _, n in ipairs(self.npcs) do 
		if Entity.IsValid(n) then 
			table.insert(newArr, n)
		end
	end
	
	self.npcs = newArr
end

function UserHeroSelectScript:StopHeroSelect()
	print("Stopping hero select")
	self.running = false
	self.heroSelectScript = nil
	self:GetEntity():SetCamera(self:GetEntity():GetPlayer())
	self:RemoveNpcs()
	self:GetEntity():GetPlayer():SetInputLocked(false)
	
	self:GetEntity().userRoomScript:CloseAll()
	if not self.cb then 
		self:GetEntity().userRoomScript:ShowWidget()
	end

	print("Finished stopping hero select")
end

function UserHeroSelectScript:ShowHero(heroDoc, dir)
	self:Schedule(function()
		local startPos, endPos
		
		self.heroSelectScript.properties.door:PlayAnimation("Closing")
		
		--Wait(0.5)
		
		if dir == 1 then 
			startPos = self.heroSelectScript.properties.npcStartPosition
			endPos = self.heroSelectScript.properties.npcEndPosition	
		else 
			startPos = self.heroSelectScript.properties.npcEndPosition
			endPos = self.heroSelectScript.properties.npcStartPosition
		end

		if self.currentNpc and Entity.IsValid(self.currentNpc) then 
			local tmpNpc = self.currentNpc
			self.currentNpc:ClearLookAt()
			
			tmpNpc:Destroy()
			--[[
			self.currentNpc:MoveToPosition(endPos:GetPosition(), function() 
				tmpNpc:Destroy()
			end)
			]]--
		end
		
		Wait()
		
		local template = GetWorld():FindTemplate(heroDoc.templateName)

		self.currentNpc = GetWorld():Spawn(template, self.heroSelectScript.properties.npcStandPosition)
		
		while not self.currentNpc.heroScript do 
			Wait() -- apparently an npc won't have its script folders on the first frame
		end
		
		self:GetEntity().userRoomScript:UpdateDetailsForHero(self.currentNpc, heroDoc._id)
		
		
		self:GetEntity().userRoomScript.detailsWidget.properties.currIndex = self.currIndex
		self:GetEntity().userRoomScript.detailsWidget.properties.maxIndex = #self.heroes
		
		self:TrackNpc(self.currentNpc)
		
		self.currentNpc:SetLookAtPosition(self.heroSelectScript.properties.camera:GetPosition())
		
		self.heroSelectScript.properties.door:PlayAnimation("Opening")
		
		--[[
		self.currentNpc:MoveToPosition(self.heroSelectScript.properties.npcStandPosition:GetPosition(), function()
			self.currentNpc:SetLookAtPosition(self.heroSelectScript.properties.camera:GetPosition())
		end)
		]]--
	end)
end

function UserHeroSelectScript:OnButtonPressed(btn)
	if not self.running then return end 
	
	if btn == "extra2" then 
		if self.cb then 
			self.cb(nil)
		end
		self:StopHeroSelect()
	end
	
	if btn == "left" then 
		if self.currIndex > 1 then 
			self.currIndex = self.currIndex - 1
			self:ShowHero(self.heroes[self.currIndex], -1)
		end
	end
	
	if btn == "right" then 
		if self.currIndex < #self.heroes then 
			self.currIndex = self.currIndex + 1
			self:ShowHero(self.heroes[self.currIndex], 1)
		end
	end
	
	if btn == "interact" then 
		self:ConfirmHeroSelection()
	end
end

function UserHeroSelectScript:ConfirmHeroSelection()
	local isAvailable = self:GetEntity().userHeroesScript:IsAvailable(self.heroes[self.currIndex]._id)
	if not isAvailable then return end 
	
	self:FinishHeroSelection()
end

function UserHeroSelectScript:FinishHeroSelection()
	self:Schedule(function()
		Wait() -- wait a tick so the room script doesn't pick up the interact button
		self:StopHeroSelect()
		
		if self.cb then 
			self.cb(self.heroes[self.currIndex])
		else 
			self:GetEntity().userRoomScript:SelectHeroForRoom(self.heroes[self.currIndex]._id)
		end
		
	end)
end

function UserHeroSelectScript:RemoveNpcs()
	for _, n in ipairs(self.npcs) do 
		if Entity.IsValid(n) then 
			n:Destroy()
		end
	end
end

return UserHeroSelectScript
