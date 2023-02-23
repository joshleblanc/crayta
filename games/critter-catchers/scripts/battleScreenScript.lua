local BattleScreenScript = {}

-- Script properties are defined here
BattleScreenScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "hitSound", type = "soundasset" },
	{ name = "hitShake", type = "camerashakeasset" },
	{ name = "currencyTemplate", type = "template" },
	{ name = "battleColorGrading", type = "colorgradingasset" },
	{ name = "battlePostProcess", type = "postprocessasset" },
	{ name = "battleCamTemp", type = "entity" },
	{ name = "neutralColorGrading", type = "colorgradingasset" },
	{ name = "neutralPostProcess", type = "postprocessasset" },
	{ name = "battleFoundSound", type = "soundasset" },
	{ name = "battleSwooshSound", type = "soundasset" },
	{ name = "battleEscapeSound", type = "soundasset" },
	{ name = "battleWonSound", type = "soundasset" },
	{ name = "xpEarnedSound", type = "soundasset" },
	{ name = "trainerWinSound", type = "soundasset" },
	{ name = "battleLostSound", type = "soundasset" },
	{ name = "monsterFaintSound", type = "soundasset" },
	{ name = "errorSound", type = "soundasset" },
}

--This function is called on the server when this entity is created
function BattleScreenScript:LocalInit()
	local inventory = self:GetEntity().cMenuScript:FindOption("Inventory")

	inventory.properties.onClose:Listen(self, "CancelUseItem")
end

function BattleScreenScript:GetCache()
	if not self.cache then 
		self.cache = GetWorld():FindScript("entityCacheScript")
	end

	return self.cache
end

-- {
--   name = "Trainer Name",
--   monsters: {
--     monster1, monster2, monster3
--   }
-- }
--

function BattleScreenScript:StartBattleCinematicCam()
	self:GetEntity():GetUser():SetMoveOverride(Vector2D.Zero, Vector2D.Zero)
	self:GetEntity():GetUser():SetCamera(self.properties.battleCamTemp, 2)
end

function BattleScreenScript:StopBattleCinematicCam()
	self:GetEntity():GetUser():SetMoveOverride(Vector2D.New(1,1), Vector2D.Zero)
	self:GetEntity():GetUser():SetCamera(self:GetEntity(), 2)
end


function BattleScreenScript:StartBattle(opponent, cb)
	self:Schedule(function()
		if IsServer() then
			self:StartBattleCinematicCam()
			self:SendToLocal("StartBattle", opponent)
			return
		end
		
		self:GetEntity():PlaySound2D(self.properties.battleFoundSound,.5)
		self:GetEntity():PlaySound2D(self.properties.battleSwooshSound,.5)
		GetWorld().colorGrading = self.properties.battleColorGrading
		GetWorld().postProcess = self.properties.battlePostProcess
		
		Wait(1.3)
		
		self:GetEntity():SendToScripts("PlayMusic", "battle")
		
		self.opponent = opponent 
		
		local w = self:GetEntity().battleScreenWidget 
		self.widget = w
		
		self.oppMonsterIndex = 1
		self.oppMonsters = opponent.monsters
		
		self.myMonsters = self:GetMyMonsters()
		self.myMonsterIndex = self:GetFirstHealthyMonster()
		
		self:InitializeOppMonstersForBattle(opponent.wildEncounter)
		self:InitializeMyMonstersForBattle()
		
		if self.myMonsterIndex == nil then 
			self:GetEntity():GetUser():SendToScripts("AddNotification", "Something went wrong. Please rest at the hospital.")
			self:EndBattle()
			return
		end
		
		self:GetMyCurrentMonster().properties.participating = true
			
		self:UpdateWidget()
		
		w.js.data.message = "What will you do?"
		w.js.data.fullMessage = false 
		w.js.data.showMoves = false
		
		w.visible = true
		
		self:GetEntity().cMenuScript:HideBar()
		self:GetEntity():GetUser().companionHappinessWidget.visible = false
		self.inBattle = true
	end)
end

function BattleScreenScript:GetFirstHealthyMonster()
	for i, mon in ipairs(self.myMonsters) do 
		if mon:GetHp() > 0 then 
			return i
		end
	end
	
	return nil
end

function BattleScreenScript:GetMyMonsters()
	return self:GetEntity():FindScript("playerMonstersControllerScript", true):GetParty()
end

function BattleScreenScript:SealFailure(messages)
	self:GetEntity().cMenuScript:CloseAllMenuOptions()

	self:DisplayFullMessage(messages, function()
		self:ProcessNextAction()
		return false
	end)
end

function BattleScreenScript:ProcessMonsterLearnMove(mon, move, cb)
	local messages = {}
	print(move.properties.minLevel, mon:GetLevel(), mon.properties.leveledUp, mon.properties.prevLevel)
	if move.properties.minLevel <= mon:GetLevel() and not move.properties.skipped and not move.properties.equipped then 
		print("Monster needs to learn a move...")
		table.insert(messages, Text.Format("{1} wants to learn {2}", mon.properties.name, move.properties.name))
		if mon:IsMoveListFull() then 
			print("Move list is full...")
			table.insert(messages, FormatString("{1} already knows 4 moves", mon.properties.name))
			
			self:DisplayFullMessage(messages, function()
				local options = {}
				for _, m in pairs(mon:GetMoves()) do 
					if m.properties.equipped then 
						table.insert(options, { name = m.properties.name, value = m.properties.id })
					end
				end
				table.insert(options, { name = FormatString("Don't learn {1}", move.properties.name), value = -1 })
				
				self.widget.js.data.enabled = false
				self:GetEntity():GetUser():SendToScripts("Prompt", FormatString("{1} already knows 4 moves. Select a move to forget", mon.properties.name), options, function(response)
					self.widget.js.data.enabled = true
					messages = {}
					if response == -1 then 
						table.insert(messages, FormatString("{1} forget {2}", mon.properties.name, move.properties.name)) 
						move.properties.equipped = false
					else 
						local m = mon:FindMove(response)
						table.insert(messages, FormatString("{1} forget {2}", mon.properties.name, m.properties.name)) 
						table.insert(messages, FormatString("{1} learned {2}", mon.properties.name, move.properties.name)) 
						m.properties.equipped = false
						move.properties.equipped = true
						move.properties.index = m.properties.index
					end
					self:DisplayFullMessage(messages, function()
						if cb then cb() end
						return false
					end)
				end)
				
				return false
			end)
		else
			print("Move can go right ahead")
			move.properties.equipped = true
			move.properties.index = mon:GetNumMoves() + 1
			table.insert(messages, FormatString("{1} learned {2}", mon.properties.name, move.properties.name))
			self:DisplayFullMessage(messages, function()
				print("Displaying learn move message", cb)
				if cb then cb() end
				return false
			end)
		end
	else
		if cb then cb() end
	end
end

function BattleScreenScript:ProcessMonsterMoveset(mon, cb, index)
	local moves = mon:GetMovesArray()
	local index = index or 1
	self:ProcessMonsterLearnMove(mon, moves[index], function()
		if index < #moves then 
			self:ProcessMonsterMoveset(mon, cb, index + 1)
		else
			if cb then cb() end
		end
	end)
end

function BattleScreenScript:ProcessLearningMoves(cb, index)
	local messages = {}
	
	local monsters = self:GetMyMonsters()
	local index = index or 1
	
	self:ProcessMonsterMoveset(monsters[index], function()
		if index < #monsters then 
			self:ProcessLearningMoves(cb, index + 1)
		else
			if cb then cb() end
		end
	end)
end

function BattleScreenScript:ProcessPostBattle()
	print("Processing evolutions")
	self:ProcessEvolutions(function()
		print("Done processing evolutions")
		print("Processing learning moves")
		self:ProcessLearningMoves(function()
			print("Done processing learning moves")
			print("Ending battle...")
			self:EndBattle()
		end)
	end)
end

function BattleScreenScript:SendXpEvent()
	self:GetEntity():GetUser():SendXPEvent("catch-monster")
	self:GetEntity():GetUser():AddToLeaderboardValue("monsters", 1)
end

function BattleScreenScript:SealSuccess(messages)
	self:GetEntity().cMenuScript:CloseAllMenuOptions()
	
	self:DisplayFullMessage(messages, function()
		local name = self:GetEntity():GetUser():GetUsername()
		local opp = self:GetOppCurrentMonster()
		self:GetEntity():GetUser():SendToServer("NotifyEveryone", FormatString("sealed a lv. {1} {2}", opp:GetLevel(), opp.properties.name))
		
		local messages = {}
		self:RewardXp(messages)
		
		self:DisplayFullMessage(messages, function()
			self:SendToServer("SendXpEvent")
			self:GetEntity():FindScript("playerMonstersControllerScript", true):AddMonster(opp)
			self:ProcessPostBattle()
			return false
		end)
		
		return false
	end)
end

function BattleScreenScript:ProcessEvolutions(cb)
	local messages = {}
	for _, mon in ipairs(self.myMonsters) do 
		if mon.properties.participating and mon.properties.hp > 0 then 
			
			if mon.properties.evolution and mon:GetLevel() >= mon.properties.evolutionLevel then 
				local prevMon = mon
				table.insert(messages, FormatString("What!? {1} is evolving!", mon.properties.name, xpGain))
				local newMon = mon:Evolve()
				table.insert(messages, FormatString("{1} is now {2}!", prevMon.properties.name, newMon.properties.name))
			end
		end
	end
	
	self:DisplayFullMessage(messages, function()
		if cb then 
			cb()
		end
		return false
	end)
end

function BattleScreenScript:EndBattle()
	self.inBattle = false
	self:GetEntity():FindScript("playerMonstersControllerScript", true):Save()
	self:GetEntity().battleScreenWidget.visible = false
	self:GetEntity().playerEncounterScript:EndEncounter()
	self:GetEntity():SendToScripts("PlayMusic", "world")
	
	self:GetEntity().cMenuScript:ShowBar()
	GetWorld().colorGrading = self.properties.neutralColorGrading
	GetWorld().postProcess = self.properties.neutralPostProcess
	
	if self:BattleWon() and self.opponent.dialog then 
		self.opponent.dialog:SendToServer("StartDialog", self:GetEntity())
		self:GetEntity():PlaySound2D(self.properties.trainerWinSound)
	end
	self:SendToServer("StopBattleCinematicCam")
	self:GetEntity():GetUser().companionHappinessWidget.visible = true
end

function BattleScreenScript:InitializeOppMonstersForBattle(wildEncounter)
	for _, t in ipairs(self.oppMonsters) do
		if t.entity then 
			local mon = t.entity.monsterScript
			
			mon:ComputeStats()
			mon:ResetHp()
			
			mon:InitForBattle()
		
			mon.properties.isWild = wildEncounter
		else
			local mon = self:GetCache():FindEntityByTemplate(t.template).monsterScript
			
			if wildEncounter then 
				mon:SeedIvs()				
			end
			
			mon:SetLevel(t.level)
			mon:ComputeStats()
			mon:ResetHp()
			
			mon:InitForBattle()

			mon.properties.isWild = wildEncounter
			
			t.entity = mon:GetEntity()
		end
		
	end
end

function BattleScreenScript:InitializeMyMonstersForBattle()
	
	for _, mon in ipairs(self.myMonsters) do 
		mon:InitForBattle()
	end
end

function BattleScreenScript:BattleScreenUseItem()
	self.actionIndex = 0
	self.actions = {
		{ type = "item" },
		self:GetOpponentAction()
	}

	self:ProcessNextAction()
end

function BattleScreenScript:UseItem()
	self.usingItem = true
	self:GetEntity():SendToScripts("OpenMenuOption", "Inventory")
	self:DisplayFullMessage({ "Select an item..." }, function()
		if self.usingItem then 
			return false
		end
	end)
end

function BattleScreenScript:CancelUseItem()
	if not self.inBattle then return end 
	if not self.usingItem then return end
	
	self.usingItem = false
		
	self:GetEntity().cMenuScript:CloseAllMenuOptions()
	self:UpdateWidget()
	self:ContinueMessage()
end

function BattleScreenScript:AfterUsedItem(messages)
	self.usingItem = false
		
	self:GetEntity().cMenuScript:CloseAllMenuOptions()
	self:UpdateWidget()
	self:DisplayFullMessage(messages, function()
		self:ProcessNextAction()
		return false
	end)

end

function BattleScreenScript:CanContinueBattle()
	for _, mon in ipairs(self.myMonsters) do 
		if mon.properties.hp > 0 then 
			return true
		end
	end
	return false
end

function BattleScreenScript:GetOppCurrentMonster()
	return self.oppMonsters[self.oppMonsterIndex].entity.monsterScript
end

function BattleScreenScript:GetMyCurrentMonster()
	print("Getting current monster", self.myMonsterIndex)
	return self.myMonsters[self.myMonsterIndex]
end

function BattleScreenScript:CloseFullMessage()
	print("Closing full message")
	local w = self:GetEntity().battleScreenWidget
	
	self.fullMessage = false
	self.messages = nil
	w.js.data.fullMessage = false
	w.js.data.showMoves = false
	w.js.data.message = "What will you do?"
end

function BattleScreenScript:ContinueMessage()
	print("Continuing message")
	if self:HasNextMessage() then 
		self:DisplayNextMessage()
	else
		if self.afterMessage then 
			local result = self.afterMessage()
			if result ~= false then 
				print("Closing because result isn't false")
				self:CloseFullMessage()
				self.afterMessage = nil
			end
		else
			print("Closing because there's no callback")
			self:CloseFullMessage()
		end
	end
end

function BattleScreenScript:HasNextMessage()
	if self.messages then 
		return self.messageIndex < #self.messages 
	else 
		return false
	end
	
end

function BattleScreenScript:DisplayNextMessage()
	self.messageIndex = self.messageIndex + 1
	self:DisplayFullMessage()
end

function BattleScreenScript:DisplayFullMessage(messages, cb)
	print("Displaying messages", messages and #messages)
	if messages and #messages == 0 then 
		if cb then cb() end
		return
	end
	
	if messages then 
		self.messages = messages
		self.messageIndex = 1
	end
	
	if cb then 
		self.afterMessage = cb
	end
	
	local w = self:GetEntity().battleScreenWidget 
	
	w.js.data.message = self.messages[self.messageIndex]
	print("Setting message to", self.messages[self.messageIndex])
	w.js.data.fullMessage = true
	w.js.data.showMoves = false
	
	self.fullMessage = true
end

function BattleScreenScript:UpdateWidget()
	local w = self:GetEntity().battleScreenWidget 
	
	w.js.data.opponent = self:GetOppCurrentMonster():ForWidget()
	w.js.data.friendly = self:GetMyCurrentMonster():ForWidget()
end

function BattleScreenScript:Show()
	self:GetEntity().battleScreenWidget.visible = true
end

function BattleScreenScript:Hide()
	self:GetEntity().battleScreenWidget.visible = false
end

function BattleScreenScript:ConfusionDamage(mon)
	local power = 40
	
	local r = math.random(217, 255) / 255
	
	return math.floor(((((((2 * mon:GetLevel()) / 5) + 2) * power ) / 50) + 2) * r)
end

-- https://bulbapedia.bulbagarden.net/wiki/Damage
function BattleScreenScript:CalculateDamage(mon, opp, move, isCritical)
	if move.properties.power <= 0 then 
		return 0
	end
	
	local critMultiplier = 1
	if isCritical then 
		critMultiplier = 2
	end
	
	local atkStat
	local defStat
	
	if isCritical then 
		if move.properties.category == "special" then 
			atkStat = mon:GetStat("spatk"):Level()
			defStat = opp:GetStat("spdef"):Level()
		else
			atkStat = mon:GetStat("atk"):Level()
			defStat = opp:GetStat("def"):Level()
		end
	else
		if move.properties.category == "special" then 
			atkStat = mon:GetStatLevel("spatk")
			defStat = opp:GetStatLevel("spdef")
		else
			atkStat = mon:GetStatLevel("atk")
			defStat = opp:GetStatLevel("def")
		end
	end
	
	local diff = atkStat / defStat
	
	
	
	local stab = 1
	if move.properties.type == mon.properties.type then 
		stab = 1.5
	end
	
	local r = math.random(217, 255) / 255
	
	local dmg = math.floor(((((((2 * mon:GetLevel() * critMultiplier) / 5) + 2) * move.properties.power * diff) / 50) + 2) * stab * move:DamageMultiplier(opp))
	
	if dmg == 1 then 
		r = 1
	end
	
	print("Calculating damage", move:DamageMultiplier(opp))	
	
	return math.floor(dmg * r)
end

function BattleScreenScript:GetNumberParticipatingMonsters()
	local sum = 0
	for _, mon in ipairs(self.myMonsters) do
		if mon.properties.participating and mon:GetHp() > 0 then 
			sum = sum + 1
		end
	end
	return sum
end

function BattleScreenScript:CalculateExperienceGain(mon)
	local b = mon:GetXpReward()
	local L = mon:GetLevel()
	
	local s = self:GetNumberParticipatingMonsters()
	
	local e = 1 -- 1.5 if player is holding a lucky egg
	local a = 1
	if not mon.properties.isWild then 
		a = 1.5
	end
	
	local t = 1 -- 1.5 if pokemon was traded
	
	local happiness = self:GetEntity():GetUser().companionScript.properties.companionHappiness / 100
	
	print("Calculating xp gain", b, L, s, e, a, t)
	return math.max(1, math.floor(((b * L) / 7) * (1/s) * e * a * t * happiness))
end

function BattleScreenScript:GetOpponentAction()
	return {
		type = "move",
		mon = self:GetOppCurrentMonster(),
		opp = function() 
			return self:GetMyCurrentMonster()
		end,
		move = self:GetOpponentMove(),
		ai = true
	}
end

function BattleScreenScript:BattleScreenUseMove(id)
	local mon = self:GetMyCurrentMonster()
	local move = mon:FindMove(id)
	local opp = self:GetOppCurrentMonster()
	
	if move.properties.remainingMoves > 0 then 
		move.properties.remainingMoves = move.properties.remainingMoves - 1
		
		local mySpeed = mon:GetStatLevel("speed")
		local oppSpeed = opp:GetStatLevel("speed")
		
		self.actionIndex = 0	
		
		if mySpeed >= oppSpeed then 
			self.actions = {
				{
					type = "move",
					mon = mon,
					move = move,
					opp = opp
				},
				self:GetOpponentAction()
			}
		else 
			self.actions = {
				self:GetOpponentAction(),
				{
					type = "move",
					mon = mon,
					move = move,
					opp = opp
				}
			}
		end
		
		self:ProcessNextAction()
	else
		self:GetEntity():PlaySound2D(self.properties.errorSound)
		self:DisplayFullMessage({
			FormatString("Your {1} can't use that move right now!", mon.properties.name)
		}, function()
			-- do I need to do anything here?
		end)
	end 
end

function BattleScreenScript:GetOpponentMove()
	local opp = self:GetOppCurrentMonster()
	local moves = opp:GetMoves()
	
	local applicableMoves = {}
	for id, move in pairs(moves) do 
		if move.properties.minLevel <= opp:GetLevel() then 
			table.insert(applicableMoves, move)
		end
	end
	
	table.sort(applicableMoves, function(a,b)
		return a.properties.minLevel > b.properties.minLevel
	end)
	
	local move = applicableMoves[math.random(1, math.min(4, #applicableMoves))]
	
	return move
end

function BattleScreenScript:OpponentUseMove()
	local move = self:GetOpponentMove()
	
	print("Opponent doing move", #applicableMoves, move)
	
	self:UseMove(opp, move, self:GetMyCurrentMonster(), true)
end

function BattleScreenScript:CalculatePrize()
	local highestLevel = 0
	for _, mon in ipairs(self.oppMonsters) do 
		if mon.level > highestLevel then 
			highestLevel = mon.level
		end
	end
	
	return self.opponent.reward * highestLevel
end

--[[

| ||

|| |_

]]--
function BattleScreenScript:CalculateLoss()
	local highestLevel = 0
	for _, mon in ipairs(self.myMonsters) do 
		local level = mon:GetLevel()
		if level > highestLevel then 
			highestLevel = level
		end
	end
	
	local db = self:GetEntity():GetUser().documentStoresScript:GetDb("progress")
	local rec = db:FindOne() or {}
	
	local badges = rec.badges or 0
	
	return highestLevel * ((badges + 1) * 8)
end

function BattleScreenScript:RewardXp(messages)
	local xpGain = self:CalculateExperienceGain(self:GetOppCurrentMonster())
	local xpSound = self:GetEntity():PlaySound2D(self.properties.xpEarnedSound)
		
	for _, mon in ipairs(self.myMonsters) do 
		if mon.properties.participating and mon.properties.hp > 0 then 
			local levelBefore = mon:GetLevel()
			
			mon:AddXp(xpGain)
			
			table.insert(messages, FormatString("{1} gained {2} exp.", mon.properties.name, xpGain))
			if levelBefore < mon:GetLevel() then 
				table.insert(messages, FormatString("{1} reached level {2}", mon.properties.name, mon:GetLevel()))
				mon.properties.leveledUp = true
				mon.properties.prevLevel = levelbefore
			end
		end
	end
end

function BattleScreenScript:BattleScreenSelectNewMonster()
	self.actionIndex = 0
	self.actions = {
		{
			type = "switch",
			safe = false
		},
		self:GetOpponentAction()
	}
	self:ProcessNextAction()
end

function BattleScreenScript:SelectNewMonster(safe)
	print("Select new monster", safe)
	self:GetEntity().cMenuScript:OpenMenuOption("Monsters")
	self.widget.js.data.enabled = false
	self:GetEntity():GetUser():SendToScripts("Prompt", "Select a monster to send to battle", {}, function(index)
		self.widget.js.data.enabled = true
		if index then 
			if self.myMonsters[index]:GetHp() == 0 then 
				print("You selected a dead monster, retrying")
				self:SelectNewMonster(safe)
			end
		
			self.myMonsterIndex = index
			self:GetMyCurrentMonster().properties.participating = true
			
			if not safe then 
				print("Not safe, being attacked, gl")
				self:ProcessNextAction()
			end
		end
		
		
		self:UpdateWidget()
		
		self:GetEntity().cMenuScript:CloseAllMenuOptions()
	end)
end

function BattleScreenScript:ProcessMove(mon, move, opp, ai, messages)
	local targetWord
	local oppositeWord
	if ai then 
		targetWord = "Enemy"
		oppositeWord = "Your"
	else 
		targetWord = "Your"
		oppositeWord = "Enemy"
	end
	
	local accuracy
	if move.properties.accuracy == -1 then 
		accuracy = 100
	else
		accuracy = mon:ModifyStat("acc", move.properties.accuracy) * opp:ModifyStat("eva", 1)
	end
	
	local doesHit = math.random(1, 100) <= accuracy
	local isCrit = math.random(1, 255) < (mon:GetStatLevel("speed") / 2)
	
	local damage = self:CalculateDamage(mon, opp, move, isCrit)
	local multiplier = move:DamageMultiplier(opp) 
	
	if doesHit then 
		self:GetEntity():PlaySound2D(self.properties.hitSound)
		
		
		if move.properties.category ~= "status" then 
			if multiplier == 2 then 
				table.insert(messages, "It's super effective!")
				self:GetEntity():GetUser():PlayCameraShakeEffect(self.properties.hitShake, .4)
			end
			if multiplier == 0.5 then 
				table.insert(messages, "It's not very effective...")
				self:GetEntity():GetUser():PlayCameraShakeEffect(self.properties.hitShake, .2)
			end
			
			if isCrit then
				table.insert(messages, "Critical hit!")
				self:GetEntity():GetUser():PlayCameraShakeEffect(self.properties.hitShake, 1)
			end
		end
		
		self.state = {
			from = mon,
			to = opp,
			ai = ai,
			move = move,
			damage = damage,
			multiplier = multiplier,
			messages = messages
		}
		move:ApplyEffect(self)
		
		if move.properties.category ~= "status" then 
			print("Applying damage", damage)
			opp:ApplyDamage(damage)
		end
		
		self:UpdateWidget()
	else
		table.insert(messages, FormatString("{1} {2} avoided the attack!", oppositeWord, opp.properties.name))
	end
end

function BattleScreenScript:UseMove(from, move, to, ai, messages)
	print("Using move", ai)
	
	self.escapeAttempts = 0
	
	local mon = from
	local opp = to
	
	mon.lastMove = move
	self.endMoveEarly = false 
			
	local targetWord
	local oppositeWord
	if ai then 
		targetWord = "Enemy"
		oppositeWord = "Your"
	else 
		targetWord = "Your"
		oppositeWord = "Enemy"
	end
	
	messages = messages or {}
	table.insert(messages, FormatString("{1} {2} used {3}", targetWord, mon.properties.name, move.properties.name))
	
	for i=1,move.properties.numAttacks do 
		self:ProcessMove(mon, move, opp, ai, messages)
		if self.endMoveEarly then 
			self.endMoveEarly = false 
			return
		end
	end
	
	if mon.properties.confused then 
		local confusionChance = math.random() < 0.5
		if confusionChance then 
			table.insert(messages, FormatString("{1} {2} hit itself in confusion!", targetWord, mon.properties.name))
			mon:ApplyDamage(self:ConfusionDamage(mon))
			if mon:GetHp() <= 0 then 
				print("Processing monster faint due to confusion")
				self:ProcessMonsterFaint(opp, not ai, targetWord, messages)
			end
		end
	end
	
	if mon.properties.poisoned then 
		table.insert(messages, FormatString("{1} {2} took damage from poison!", targetWord, mon.properties.name))
		mon:ApplyDamage(math.floor(mon:GetMaxHp() / 16))
		if mon:GetHp() <= 0 then 
			print("Processing monster faint due to poison")
			self:ProcessMonsterFaint(opp, not ai, targetWord, messages)
		end
	end
	
	self:UpdateWidget()
	
	if opp:GetHp() <= 0 then 
		print("Processing monster faint due to attack")
		self:ProcessMonsterFaint(opp, ai, oppositeWord, messages)
	else 
		self:UpdateWidget()
		self:DisplayFullMessage(messages, function()
			if self:IsBattleOver() then 
				self:ProcessPostBattle()
				
				print("Process post battle done, returning false")
				return false
			else
				return self:ProcessNextAction()
			end
			
			print("Use move messages finished, returning nil....")
		end)
	end
end

function BattleScreenScript:ProcessOutOfMonsters(messages)
	messages = messages or {}
	
	local loss = self:CalculateLoss()
	
	table.insert(messages, "You're out of monsters!")
	table.insert(messages, "You blacked out!")
	table.insert(messages, FormatString("You lost {1}$", loss))
	
	self:DisplayFullMessage(messages, function()
		self:GetEntity():PlaySound2D(self.properties.battleLostSound)
		self:EndBattle()
		self:GetEntity():SendToScripts("RevivePlayer")
	end)
end

function BattleScreenScript:RewardEv(monster)
	local numParticipants = self:GetNumberParticipatingMonsters()
	
	for _, mon in ipairs(self.myMonsters) do 
		if mon.properties.participating and mon.properties.hp > 0 then 
			for id, stat in pairs(monster:GetEntity().statsScript:GetStats()) do 
				if id ~= "level" then 
					mon:AddEv(id, math.floor(stat.properties.baseLevel / numParticipants))
				end
			end
		end
	end
end

function BattleScreenScript:ProcessMonsterFaint(opp, ai, targetWord, messages)
	print("processing monster faint")
	table.insert(messages, FormatString("{1} {2} fainted!", targetWord, opp.properties.name))
	
	local faintSound = self:GetEntity():PlaySound2D(self.properties.monsterFaintSound)
	faintSound:SetPitch(2)
	
	if ai then 
		if self:CanContinueBattle() then 
			self:DisplayFullMessage(messages, function()
				print("While processing monster faint, select new monster")
				self:SelectNewMonster(true)
			end)
			
		else
			self:ProcessOutOfMonsters(messages)
		end
	else 
	
		self:RewardXp(messages)
		self:RewardEv(opp)
	
		if self.oppMonsterIndex < #self.oppMonsters then 
			self.oppMonsterIndex = self.oppMonsterIndex + 1
			
			local str = FormatString("{1} is going to send out {2}", targetWord, self:GetOppCurrentMonster().properties.name)
			table.insert(messages, str)
			
			self:DisplayFullMessage(messages, function()
				self:GetEntity():GetUser():SendToScripts("LocalConfirm", FormatString("{1}. Do you want to switch monsters?", str), function(result)
					if result then 
						print("Trainer is about to send out new monster, select new monster?")
						self:SelectNewMonster(true)
					else 
						self:UpdateWidget()
					end
				end)
			end)
		else 
			table.insert(messages, FormatString("Battle won!"))
			
			if not self.opponent.wildEncounter then 
				local prize = self:CalculatePrize()
				self:GetEntity():GetUser("AddToInventory", self.properties.currencyTemplate, prize)
				table.insert(messages, FormatString("You won {1}$", prize))
			end
			
			
			if self.opponent.questId then 
				self:GetEntity():GetUser():SendToScripts("CompleteQuest", self.opponent.questId)
			end
			
			self:UpdateWidget()
			self:DisplayFullMessage(messages, function()
				if self:IsBattleOver() then 
					self:ProcessPostBattle()
					return false
				elseif not ai then
					self:ProcessNextAction()
					return false
				end
			end)
		end
	end
end

function BattleScreenScript:ProcessNextAction()
	self.actionIndex = self.actionIndex + 1
	local action = self.actions[self.actionIndex]
	
	if not action then return end
	
	if action.type == "move" then 
		local opp = action.opp 
		if type(opp) == "function" then 
			opp = action.opp()
		end
		
		self:UseMove(action.mon, action.move, opp, action.ai)
		return false
	end
	
	if action.type == "switch" then
		self:SelectNewMonster(action.safe)	
		return false
	end
	
	if action.type == "item" then 
		self:UseItem()
		return false
	end
	
	if action.type == "escape" then 
		self:Escape()
		return false
	end
end

function BattleScreenScript:HasAnyMonstersRemaining()
	for _, mon in ipairs(self:GetMyMonsters()) do 
		if mon.properties.hp > 0 then 
			return true
		end
	end
	
	return false
end

function BattleScreenScript:BattleWon()
	return self:IsBattleOver() and self:HasAnyMonstersRemaining()
end

function BattleScreenScript:IsBattleOver()
	return self.oppMonsterIndex == #self.oppMonsters and self:GetOppCurrentMonster().properties.hp <= 0
end

function BattleScreenScript:BattleScreenEscape()
	self.actionIndex = 0
	self.actions = {
		{ type = "escape" },
		self:GetOpponentAction()
	}
	self:ProcessNextAction()
end

function BattleScreenScript:GetEscapeOdds()
	local mon = self:GetMyCurrentMonster()
	local opp = self:GetOppCurrentMonster()
	
	local speed = mon:GetStatLevel("speed")
	local oppSpeed = opp:GetStatLevel("speed")
	
	if speed >= oppSpeed then 
		return 256
	end
	
	self.escapeAttempts = self.escapeAttempts or 0
	self.escapeAttempts = self.escapeAttempts + 1
	
	local a = speed * 32
	local b = math.floor(oppSpeed / 4) % 256
	local c = math.floor(a / b) + (30 * self.escapeAttempts)
	
	if b == 0 then 
		return 256
	else
		return c
	end
end

function BattleScreenScript:Escape()
	if self.opponent.wildEncounter then 
		local w = self:GetEntity().battleScreenWidget 
		local sound = self:GetEntity():PlaySound2D(self.properties.battleEscapeSound)
		sound:SetPitch(2)
		
		local escapeOdds = self:GetEscapeOdds()
		local r = math.random(0, 255)
		
		print("Escape", escapeOdds, r)
		if escapeOdds > 255 or r < escapeOdds then 
			self:DisplayFullMessage({ "You Escaped!" }, function()
				self:EndBattle()
			end)
		else
			self:DisplayFullMessage({ "You couldn't get away!" }, function()
				self:ProcessNextAction()
				return false
			end)
		end

	else
		self:GetEntity():GetUser():SendToScripts("AddNotification", "You can't escape from a trainer battle!")
	end
end

return BattleScreenScript
