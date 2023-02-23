local AdventureScript = {}

AdventureScript.Properties = {
}

-- simple OnUserLogin callback, sent by the game
-- when a user logs in. This one calls Load on autoSaveScript
-- and then spawns a player for the user when everything loaded...
function AdventureScript:OnUserLogin(user)
	
	user.autoSaveScript:Load(
		function()
			Print("Adventure: Spawning")
			--user:SpawnPlayer(nil)
		end	
	)
	
end

-- when a user leaves make sure they are saved...
function AdventureScript:OnUserLogout(user)
	user.autoSaveScript:Unload()
end

return AdventureScript
