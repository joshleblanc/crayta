--[[
This script builds upon the Shuffle Table community package.

To use this script, add it to your application. I typically add it to the Game template
Next, call the ShuffleTeams method. I typically do this using the onRoundStart event handler on the 
game controller. However, you can call it manually by using entity:SendToScripts("ShuffleTeams"), or 
script:SendToScript("ShuffleTeams") if you have access to the script itself.

Please make sure you've added the script to an entity inside the world, otherwise the event will not
be called, even if wired up properly.

]]--

local ShuffleTeamsScript = {}

-- Script properties are defined here
ShuffleTeamsScript.Properties = {
	{ name = "numberOfTeams", type = "number", default = 2 }
}

-- The following function is taken from the Shuffle Table package
-- and is unaltered. 
-- Input a table you'd like to shuffle
-- Return is a shuffled table
function ShuffleTeamsScript:shuffle(tInput)
	local tReturn = {} 
	for i = #tInput, 1, -1 do
		local j = math.random(i)
		tInput[i], tInput[j] = tInput[j], tInput[i]
		table.insert(tReturn, tInput[i])
	end
	return tReturn
end

function ShuffleTeamsScript:ShuffleTeams()
    print("Shuffling players")
    local shuffledUsers = self:shuffle(GetWorld():GetUsers())
    local team = math.random(self.properties.numberOfTeams)
    for k, user in pairs(shuffledUsers) do
        Printf("Shuffle: Putting {1} on team {2}", user:GetName(), team)
        user:SendToScripts("SetTeam", team, true)
        team = team + 1
        if team > self.properties.numberOfTeams then
        	team = 1
        end 
    end
end

return ShuffleTeamsScript
