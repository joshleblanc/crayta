local ComedyGameScript = {}

-- Script properties are defined here
ComedyGameScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "camera", type = "entity" },
	{ name = "missSounds", type = "soundasset", container = "array" },
	{ name = "hitSounds", type = "soundasset", container = "array" },
	{ name = "running", type = "boolean", default = false, editable = false },
	{ name = "shakeAsset", type = "camerashakeasset" },
	{ name = "controllerVibration", type = "vibrationeffectasset" },
	{ name = "startPosition", type = "entity" },
	{ name = "path", type = "entity" },
	{ name = "curtains", type = "entity" },
	{ name = "spawnPosition", type = "entity" }
}

--jokes = { { "How many programmers does it take to screw in a light bulb?", "None. It's a hardware problem." },{ "Why did the web developer walk out of a resturant in disgust?", "The seating was laid out in tables." },{ "Why is 6 afraid of 7 in hexadecimal Canada?", "Because 7 8 9 A?" },{ "Hey, wanna hear a joke?", "Parsing HTML with regex." },{ "Why do programmers confuse Halloween and Christmas?", "Because Oct 31 = Dec 25" },{ "Why does no one like SQLrillex?", "He keeps dropping the database." },{ "What do you call a developer who doesn't comment code?", "A developer." },{ "Why did the Python programmer not respond to the foreign mails he got?", "Because his interpreter was busy collecting garbage." },{ "Why did the programmer quit his job?", "Because he didn't get arrays." },{ "How can you tell an extroverted programmer?", "He looks at YOUR shoes when he's talking." },{ "Why are modern programming languages so materialistic?", "Because they are object-oriented." },{ "What do you get if you lock a monkey in a room with a typewriter for 8 hours?", "A regular expression." },{ "What do you call a group of 8 Hobbits?", "A Hobbyte." },{ "Why did the JavaScript heap close shop?", "It ran out of memory." },{ "What is the best prefix for global variables?", "//" },{ "What's the object-oriented way to become wealthy?", "Inheritance." },{ "Why did the functional programmer get thrown out of school?", "Because he refused to take classes." },{ ".NET developers are picky when it comes to food.", "They only like chicken NuGet." },{ "Why do programmers wear glasses?", "Because they need to C#" },{ "So what's a set of predefined steps the government might take to preserve the environment?", "An Al-Gore-ithm." },{ "Why do Java programmers hate communism?", "They don't want to live in a classless society." },{ "Hey baby I wish your name was asynchronous...", "... so you'd give me a callback." },{ "What is a dying programmer's last program?", "Goodbye, world!" },{ "I asked my wife if I was the only one she's been with.", "She said, \"Yes, the others were at least sevens or eights.\"" },{ "Thank you student loans for getting me through college.", "I don't think I'll ever be able to repay you." },{ "Did you hear about the cheese factory that exploded in France?", "There was nothing but de brie." },{ "What kind of car did Whitney Houston drive?", "A Hyundaiiiiiiiiiiii" },{ "What is the least spoken language in the world?", "Sign language." },{ "I WRITE MY JOKES IN CAPITALS.", "THIS ONE WAS WRITTEN IN PARIS." },{ "So I made a graph of all my past relationships.", "It has an ex axis and a why axis." },{ "My wife left me because I'm too insecure and paranoid.", "Oh wait, never mind. She was just getting the mail." },{ "My wife divorced me so I stole her wheelchair.", "Guess who came crawling back." },{ "Why did the Romanian stop reading?", "They wanted to give the Bucharest." },{ "I hate Russian matryoshka dolls.", "They're so full of themselves." },{ "Mom asked me where I'm taking her to go out to eat for mother's day.", "I told her, \"We already have food in the house\"." },{ "What's the difference between an in-law and an outlaw?", "An outlaw is wanted." },{ "My mother said, \"You won't amount to anything because you always procrastinate.\"", "I said, \"Oh yeah... Just you wait.\"" },{ "What time did the man go to the dentist?", "Tooth hurt-y." },{ "How do you generate a random string?", "Put a Windows user in front of Vim and tell them to exit." },{ "What do you call a pile of kittens?", "A meowntain." },{ "What kind of doctor is Dr. Pepper?", "He's a fizzician." },{ "What's the difference between a hot potato and a flying pig?", "One's a heated yam, the other's a yeeted ham." },{ "This morning I accidentally made my coffee with Red Bull instead of water.", "I was already on the highway when I noticed I forgot my car at home." },{ "How did you make your friend rage?", "I implemented a greek question mark in his JavaScript code." },{ "The gas Argon walks into a bar. The barkeeper says \"What would you like to drink?\"", "But Argon doesn't react." },{ "Dads are like boomerangs.", "I hope." },{ "Two guys walked into a bar.", "The third guy ducked." },{ "Two peanuts were walking.", "One was assaulted." },{ "A grocery store cashier asked if I would like my milk in a bag.", "I told her \"No, thanks. The carton works fine\"." },{ "What do you call a witch at the beach?", "A Sandwich." },{ "What do you call 4 Mexicans in quicksand?", "Quatro Sinko." },{ "Why was the river rich?", "Because it had two banks." },{ "Why didn't the skeleton go for prom?", "Because it had nobody." },{ "What did the customer say to the waiter?", "I'm all fed up with your service." },{ "Why did the koala get rejected?", "Because he did not have any koalafication." },{ "What is the most used language in programming?", "Profanity." },{ "What's the best thing about Switzerland?", "I don't know, but the flag is a big plus." },{ "What do you call a cow with no legs?", "Ground beef." },{ "The past, the present and the future walk into a bar.", "It was tense." },{ "What did the cell say when his sister cell stepped on his foot?", "Mitosis." },{ "How did Harry Potter get down the hill?", "Walking... JK, Rolling." },{ "Why did the chicken cross the road, roll in the mud and cross the road again?", "He was a dirty double-crosser!" },{ "What do you call a deer with no eyes?", "No eye deer." },{ "What are bits?", "Tiny things left when you drop your computer down the stairs." },{ "Where do sick cruise ships go to get healthy?", "The dock!" },{ "Has COVID-19 forced you to wear glasses and a mask at the same time?", "If so, you may be entitled to condensation." },{ "Why did the programmer jump on the table?", "Because debug was on his screen." },{ "I walked into a bar once.", "It really hurt my head." },{ "How do construction workers party?", "They raise the roof." },{ "Why do cows wear bells?", "Because their horns don't work!" },{ "Why was the mushroom always invited to parties?", "Cause he's a fungi." },{ "Why do they call it hyper terminal?", "Too much Java." },{ "How much did your chimney cost?", "Nothing, it was on the house." },{ "Why do programmers prefer using the dark mode?", "Because light attracts bugs." },{ "Why did the Python data scientist get arrested at customs?", "She was caught trying to import pandas!" },{ "What does Santa suffer from if he gets stuck in a chimney?", "Claustrophobia!" },{ "Why does Santa have three gardens?", "So he can 'ho ho ho'!" },{ "Why did Santa's helper see the doctor?", "Because he had a low \"elf\" esteem!" },{ "What kind of motorbike does Santa ride?", "A Holly Davidson!" },{ "What says Oh Oh Oh?", "Santa walking backwards!" },{ "Who is Santa's favourite singer?", "Elf-is Presley!" },{ "What's Santa's favourite type of music?", "Wrap!" },{ "What do Santa's little helpers learn at school?", "The elf-abet!" },{ "What do elves post on Social Media?", "Elf-ies!" },{ "Who hides in the bakery at Christmas?", "A mince spy!" },{ "Why couldn't the skeleton go to the Christmas party?", "Because he had no body to go with!" },{ "Why does Santa go down the chimney?", "Because it soots him!" },{ "Why do front end developers eat lunch alone?", "Because they don't know how to join tables." },{ "Why are cats so good at video games?", "They have nine lives." },{ "Why did the banana go see a doctor?", "Because it wasn't peeling well." },{ "Why is Linux safe?", "Hackers peak through Windows only." },{ "Why are Assembly programmers always soaking wet?", "They work below C-level." },{ "Why did the database administrator leave his wife?", "She had one-to-many relationships." },{ "What's the difference between a poorly dressed man on a unicycle and a well dressed man on a bicycle?", "Attire." },{ "Why shouldn't you visit an expensive wig shop?", "It's too high a price \"toupee.\"" },{ "You see, mountains aren't just funny.", "They are hill areas." },{ "Did you hear about the claustrophobic astronaut?", "He just needed a little space." },{ "\"99.9% of the people are dumb!\"", "\"Fortunately I belong to the remaining 1%\"" },{ "No matter how kind you are...", "German kids are always Kinder." },{ "Which is faster, Hot or cold?", "Hot, because you can catch a cold" },{ "To prove he was right, the flat-earther walked to the end of the Earth.", "He eventually came around." },{ "I just saw my wife trip over and drop a basket full of ironed clothes.", "I watched it all unfold." },{ "I was feeling depressed, my wife put her hand on my back and said \"Earth.\"", "It meant the world to me." },{ "My employer came running to me and said, \"I was looking for you all day! Where the hell have you been?\"", "I replied, \"Good employees are hard to find.\"" },{ "The other day my wife asked me to pass her lipstick, but I accidentally gave her a glue stick.", "She still isn't talking to me." },{ "Which part of the hospital has the least privacy?", "The ICU." },{ "A Roman walks into a bar and raises 2 fingers and says to the bartender...", "\"Five beers, please.\"" },{ "I stayed up all night wondering where the sun went.", "Then it dawned on me." },{ "Why does the size of the snack not matter to a giraffe?", "Because even a little bit goes a long way." },{ "Why was the JavaScript developer sad?", "Because they didn't Node how to Express themself!" },{ "Whats the Grinchs least favorite band?", "The Who." },{ "why do python programmers wear glasses?", "Because they can't C." },{ "Why do ghosts go on diets?", "So they can keep their ghoulish figures." },{ "What is in a ghost's nose?", "Boo-gers." },{ "What's it like to be kissed by a vampire?", "It's a pain in the neck." },{ "What does a turkey dress up as for Halloween?", "A gobblin'!" },{ "Why did the ghost go inside the bar?", "For the boos." },{ "I just got fired from my job at the keyboard factory.", "They told me I wasn't putting in enough shifts." },{ "I can't believe I got fired from the calendar factory.", "All I did was take a day off." },{ "What's the difference between England and a tea bag?", "The tea bag stays in the cup longer." },{ "Do you know what killed the man who had a two ton pumpkin fall on him?", "He was squashed." },{ "I'm not saying my son is ugly...", "But on Halloween he went to tell the neighbors to turn down their TV and they gave him some candy." },{ "What happened to the man who got behind on payments to his exorcist?", "He got repossessed." },{ "Did you hear about the crime in the parking garage?", "It was wrong on so many levels." },{ "What do you call a caveman's fart?", "A blast from the past." },{ "Why should you never talk to pi?", "Because it will go on forever." } }
jokes = { { "Why did the Headless Horseman go to school?", "He wanted to get a-head in life." }, { "Why do witches wear name tags?", "To tell which witch is which." }, { "What did the ghost say when it fell down?", "I got a boo-boo." }, { "What kind of rocks do ghosts collect?", "Tombstones." }, { "Did you hear about the zombie that took a nap?", "It was dead tired." }, { "When do cows turn into werewolves?", "During the full moooooon." }, { "Did you hear about the crazy vampire?", "He was totally batty." }, { "Where do ghosts buy stamps?", "At the ghost office." }, { "Why did the ghost go to a bar?", "It was looking for boo’s." }, { "What kind of shoes do ghosts wear?", "Boo-ts." }, { "Why don’t ghosts lie?", "Because you can see right through them." }, { "What kind of muffins do ghosts prefer?", "Boo-berry." }, { "Why did the ghost cross the road?", "He wanted to return from the other side." }, { "How do ghosts unlock doors?", "With spoo-keys." }, { "Did you hear about the ghost party?", "It was loud enough to wake the dead." }, { "Why don’t ghosts shower?", "It dampens their spirits." }, { "Where do ghosts shop?", "Boo-tiques." }, { "What’s a ghost’s favorite dinner?", "Spook-etti." }, { "Why did the ghost ride the elevator?", "To lift its spirit." }, { "How do ghosts apply for jobs?", "They fill out apparitions." }, { "Why don’t ghosts do standup comedy?", "They always get booed." }, { "What do ghosts use to style their hair?", "Scare-spray." }, { "How do ghosts predict the future?", "They check their horror-scope." }, { "What do ghosts wear if they can’t see?", "Spooktacles." }, { "Why do skeletons argue?", "They always have a bone to pick." }, { "Why did the skeleton skip the prom?", "It had no body to go with." }, { "Why don’t skeletons like the cold?", "It’s bone-chilling." }, { "What did the skeleton bring to the cookout?", "Spare ribs." }, { "Why don’t skeletons skydive?", "They don’t have the stomach for it." }, { "What’s a skeleton’s favorite musical instrument?", "The trom-bone." }, { "What do you call a skeleton that won’t do any work?", "Lazy bones." }, { "How do skeletons start their cars?", "With skeleton keys." }, { "Why did the skeleton put on a sweater?", "It was chilled to the bone." }, { "Why’d the skeleton go the grocery store?", "Its pantry was down to the bare bones." }, { "Why did the skeleton laugh?", "Something tickled its funny bone." }, { "What do skeleton dogs eat?", "Milk bones." }, { "How do pumpkins mend a tear?", "With a pumpkin patch." }, { "What’s a pumpkin’s favorite sport?", "Squash." }, { "Why do pumpkins bar hop?", "To get smashed." }, { "What’s a pumpkin’s favorite fruit?", "Orange." }, { "How do little pumpkins cross the road?", "With the help of a crossing gourd." }, { "What kind of pumpkins work at a pool?", "Life-gourds." }, { "Why didn’t Cinderella make the soccer team?", "Her coach was a pumpkin." }, { "Who rules the pumpkin patch?", "The pump-king." }, { "Why did the pumpkin go to jail?", "It had a bad seed." }, { "What kind of canine do pumpkins prefer?", "Gourd-dogs." }, { "How do pumpkins get paid?", "With pumpkin bread." }, { "How do pumpkins quit smoking?", "They use a pumpkin patch." }, { "What kind of music do zombies listen to?", "The Grateful Dead." }, { "What do you call identical zombie twins?", "Dead ringers." }, { "Where do zombies live?", "On a dead end." }, { "Why don’t zombies eat clowns?", "They taste funny." }, { "Did you hear about the zombie the lost the race?", "It came in dead last." }, { "What’s a zombie’s pick-up line?", "You’re drop-dead gorgeous." }, { "Did you hear about the zombie recital?", "The performance knocked ‘em dead." }, { "Why did the zombie get fired?", "It missed its dead-line." }, { "Where should you hide if you’re being chased by zombies?", "The living room." }, { "Did you hear about the zombie valedictorian?", "It was dead-icated to its studies." }, { "Why did everyone leave the zombie party?", "It wasn’t very lively." }, { "Why did the zombie lose the argument?", "It didn’t have a leg to stand on." }, { "Did you hear about the zombie who bought a new car?", "It cost an arm and a leg." }, { "What should you do if there’s a zombie attack?", "Play dead." }, { "Where do zombies swim?", "In the Dead Sea." }, { "Why did the zombie take a nap?", "It was dead on its feet." }, { "What kind of cars do zombies drive?", "Monster trucks." }, { "What do zombies order at the deli?", "Knuckle sandwich." }, { "Did you hear about the angry zombie?", "It got bent out of shape." }, { "What’s a vampire’s favorite kind of dog?", "A bloodhound." }, { "Where do vampires deposit their paychecks?", "At the blood bank." }, { "Did you hear about the vampire feud?", "There was bad blood." }, { "What do you call vampire siblings?", "Blood brothers." }, { "How can you spot a wealthy vampire?", "It has blue blood." }, { "What happens when vampires get mad?", "It makes their blood boil." }, { "How do vampires flirt?", "They bat their eyes." }, { "Why did the vampire get glasses?", "It was as blind as a bat." }, { "Why did the vampire go to the dentist?", "It had bat breath." }, { "Why don’t vampires get invited to parties?", "They’re a pain in the neck." }, { "Did you hear about the vampire romance?", "It was love at first bite." }, { "Why did the vampire go to the doctor?", "It was coffin." }, { "What shouldn’t you serve a vampire for dinner?", "Steak." }, { "Did you hear about the new vampire laptop?", "It bytes." }, { "Why do vampires avoid the cold?", "They don’t want to get frostbite." }, { "Who won the vampire race?", "No one — it was neck and neck." }, { "What do you call two witches who live together?", "Broommates." }, { "What should you get a witch on her birthday?", "A charm bracelet." }, { "What do witches’ study in school?", "Spelling." }, { "What’s a witches’ pick-up line?", "Hey, you’ve got hex appeal!" }, { "Where do witches park?", "In the broom closet." }, { "Did you hear about the witch that got school detention?", "She was ex-spelled." }, { "Did you hear about the witch that couldn’t find work?", "It was a dry spell." }, { "Why do witches drink beer?", "They enjoy a good brew." }, { "Why did the witch cancel her speech?", "There was a frog in her throat." }, { "Why did the angry witch leave her broom at home?", "She didn’t want to fly off the handle." } }
--This function is called on the server when this entity is created
function ComedyGameScript:Init()
	self.usersActive = {}
end

function ComedyGameScript:StartEvent(event)
	self.properties.running = true
	self.event = event
end

function ComedyGameScript:StopEvent(event)
	self.properties.running = false
end

function ComedyGameScript:GetEvent()
	return self.event
end

function ComedyGameScript:HandleInteract(player)
	if not self.properties.running then return end
	
	print("handling interact")
	
	local user = player:GetUser()
	
	if self:UserActive(user) then return end 
	
	user:GetPlayer():SetPosition(self.properties.startPosition:GetPosition())
	user:SendToScripts("DoOnLocal", self:GetEntity(), "OpenCurtains")
	
	user:GetPlayer().visible = false
	user:SendToScripts("DoOnLocal", self:GetEntity(), "ShowPlayer", user)
	user:GetPlayer().speedMultiplier = 0.9  
	
	self.properties.path:SendToScripts("Follow", user)
end

function ComedyGameScript:ShowPlayer(user)
	user:GetPlayer().visible = true
end

function ComedyGameScript:HidePlayer(user)
	user:GetPlayer().visible = false
end

function ComedyGameScript:OpenCurtains()
	self.properties.curtains:PlayAnimation("Opening")
end

function ComedyGameScript:CloseCurtains()
	self.properties.curtains:PlayAnimation("Closing")
end

function ComedyGameScript:RunPerformance(user, index)
	print("Running performance")
	if index ~= 3 then return end 
	
	table.insert(self.usersActive, user)
	
	user:SendToScripts("DoOnLocal", self:GetEntity(), "LocalRunPerformance", user, index)
	while self:UserActive(user) do
		Wait()
	end
end

function ComedyGameScript:UserActive(user)
	for _, u in ipairs(self.usersActive) do
		if u == user then
			return true
		end
	end
	return false
end

function ComedyGameScript:LocalRunPerformance()
	local user = GetWorld():GetLocalUser()
	
	local missed = 0
	local reactionSound 
	user:SendToScripts("DoQuickTimeEvent", function()
		for i=1,3 do 
			local joke = jokes[math.random(1, #jokes)]
			local result = user.userQuickTimeScript:RandomButtonPressQTE(2, { skipAnnouncement = true })
			
			if reactionSound then
				user:GetPlayer():StopSound(reactionSound, 1)
			end
			
			if result then
				user:SendToScripts("Shout", joke[1],5)
				
				Wait(5)
				
				result = user.userQuickTimeScript:RandomButtonPressQTE(2, { skipAnnouncement = true })
	
				if result then
					print("Nailed it")
					user:SendToScripts("Shout", joke[2],5)
					reactionSound = user:GetPlayer():PlaySound2D(self.properties.hitSounds[math.random(1, #self.properties.hitSounds)])
				else
					user:SendToScripts("Shout", "...I don't remember the punchline")
					missed = missed + 1
					user:PlayCameraShakeEffect(self.properties.shakeAsset,.5)
					reactionSound = user:GetPlayer():PlaySound2D(self.properties.missSounds[math.random(1, #self.properties.missSounds)])
				end
			else
				user:SendToScripts("Shout", "Um....")
				reactionSound = user:GetPlayer():PlaySound2D(self.properties.missSounds[math.random(1, #self.properties.missSounds)])
			end
			
			Wait(5)
		end
		
		if missed > 0 then
			user:SendToScripts("Shout", FormatString("You slipped up! Try again!", missed))
		else
			self:SendToServer("Reward", user)
		end
		
		self:CloseCurtains()
		
		Wait(2)
		
		if reactionSound then
			user:GetPlayer():StopSound(reactionSound, 1)
		end
		
		self.running = false
		
		self:SendToServer("Finish", user)
	end)
end

function ComedyGameScript:Reward(user)
	if not self.event then return end 
	
	self.event:RewardParticipation(user:GetPlayer())
end

function ComedyGameScript:Finish(user)
	local indexToRemove
	for i, u in ipairs(self.usersActive) do
		if u == user then
			indexToRemove = i
		end
	end
	table.remove(self.usersActive, i)
	
	user:GetPlayer().visible = true 
	user:GetPlayer().speedMultiplier = 1
	user:GetPlayer():SetPosition(self.properties.spawnPosition:GetPosition())
	--user:SetCamera(user:GetPlayer())
end

function ComedyGameScript:GetInteractPrompt(prompts)
	if not self.properties.running then return end 
	
	prompts.interact = "Perform StandUp"
end

return ComedyGameScript
